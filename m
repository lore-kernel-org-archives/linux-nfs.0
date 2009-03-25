Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:25622 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750738AbZCYTAI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2009 15:00:08 -0400
Message-ID: <49CA7EE5.2040905@panasas.com>
Date: Wed, 25 Mar 2009 20:58:45 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Making crossmnt a default export option
References: <49CA7D93.9050608@RedHat.com>
In-Reply-To: <49CA7D93.9050608@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mar. 25, 2009, 20:53 +0200, Steve Dickson <SteveD@redhat.com> wrote:
> Hello,
> 
> What would be the ramifications of turning on the crossmnt
> option on by default? Currently the the default is nocrossmnt.
> 
> In my recent work with pseudo exports, it has become very apparent
> that having the crossmnt always set, especially with multi file
> system exports, allows mount to "just work"!
> 
> So historically what is the reason for not allowing the clients
> to always cross file systems? Is it a security issue? 
> And again, what would be the ramifications always allowing, by
> default, clients to cross file systems?

http://www.ietf.org/rfc/rfc1813.txt:
3.3.3 Procedure 3: LOOKUP -  Lookup filename
   IMPLEMENTATION

      At first glance, in the case where what.name refers to a
      mount point on the server, two different replies seem
      possible. The server can return either the file handle for
      the underlying directory that is mounted on or the file
      handle of the root of the mounted directory.  This
      ambiguity is simply resolved. A server will not allow a
      LOOKUP operation to cross a mountpoint to the root of a
      different filesystem, even if the filesystem is exported.


> 
> steved.
>      
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
