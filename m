Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f46.google.com ([209.85.166.46]:38368 "EHLO
        mail-io1-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727350AbeJUDJY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Oct 2018 23:09:24 -0400
Received: by mail-io1-f46.google.com with SMTP id q18-v6so2805520iod.5
        for <linux-nfs@vger.kernel.org>; Sat, 20 Oct 2018 11:58:01 -0700 (PDT)
Subject: Re: readdir request re-requests entries
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
From: Frank Sorenson <sorenson@redhat.com>
Message-ID: <bfcdcc2b-5f50-538f-3584-7c8527dd93ac@redhat.com>
Date: Sat, 20 Oct 2018 13:57:58 -0500
MIME-Version: 1.0
In-Reply-To: <174380207.12564567.1539987095714.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/19/2018 05:11 PM, Mkrtchyan, Tigran wrote:
> 
> Dear NFS fellows,
> 
> we have notice a behavior of nfs client when iterating over a big
> directory. The client re-requests entries that already has been. For
> example, a client issues READDIR on a directory with 1k files. Initial cookie
> is 0, maxcount 32768.
> 
> c -> s cookie 0
> s -> c last cookie 159
> c -> s cookie 105
> s -> c last cookie 259
> c -> s cookie 207
> 
> ...
> 
> and so on. The interesting thing is, if I mount with rsize 8192 (maxcount 8192), then first couple
> or requests are asking for correct cookies - 0, 43, 81, 105. Again 105 as with maxcount 32678. To
> me it looks like that there is some kind of internal page (actually NFS_MAX_READDIR_PAGES) alignment
> and entries which do not fit into initially allocated PAGE_SIZE * NFS_MAX_READDIR_PAGES memory
> just get dropped.
> 
> As 30% of each reply is thrown away, listing of large directories may produce much more requests
> than required.
> 
> Is it an expected behavior?


Expected based on how readdir entries are handled on the client, though
you are probably correct that there is room for improvement (but may not
be the largest opportunity in the readdir code).

The number of excess directory entries retrieved from the server will
vary based on a number of factors, including kernel version, filename
length, rsize, etc.

On the client, each page of the directory inode's address space contains
an nfs_cache_array:

struct nfs_cache_array {
    unsigned int size;
    int eof_index;
    u64 last_cookie;
    struct nfs_cache_array_entry array[];
}
(size: 16)

with the array of nfs_cache_array_entry structs extending to the end of
the page:

struct nfs_cache_array_entry {
    u64 cookie;
    u64 ino;
    struct qstr string;
    unsigned char d_type;
}
(size: 40)

this means that each page can hold 102 entries:

$ echo "(4096-16)/40"|bc
102


Actual behavior depends on a number of factors, including the client's
kernel version but with the cookie sequence you mention, I suspect the
following is occurring:

* client
  READDIR call with cookie 0
* server
  READDIR reply with 156 entries, cookies numbered ?-159 (4?)
* client
  keeps 102 entries (numbered 4-105)
  READDIR call with cookie 105
* server
  READDIR reply with 154 entries, cookies numbered 106-259
* client
  keeps 102 entries (numbered 106-207)
  READDIR call with cookie 207
* server
  READDIR reply with ??? entries, cookies numbered 108-???
etc.


Frank
--
Frank Sorenson
sorenson@redhat.com
Senior Software Maintenance Engineer
Global Support Services - filesystems
Red Hat
