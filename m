Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43124 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754203AbdCHWIA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 17:08:00 -0500
Date: Wed, 8 Mar 2017 17:07:23 -0500
To: John Bazik <john_bazik@brown.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: access(2) inaccurately reports execute permissions
Message-ID: <20170308220723.GA4902@fieldses.org>
References: <20170308215058.GO27384@cs.brown.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170308215058.GO27384@cs.brown.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 08, 2017 at 04:50:58PM -0500, John Bazik wrote:
> I have evidence that the system call access(2), with mode set to X_OK,
> does not accurately report execute permissions for a file mounted via
> NFS4 and with execute provided by an NFS4 acl.
> 
> Here's a transcript:
> 
> root@radio:/testmnt# nfs4_getfacl acltestjan3017/testacls/f.test301.test261.400.u+test314=5
> A::OWNER@:rtTcCy
> A::test314@ad.brown.edu:rxtcy
> A::GROUP@:tcy
> A::EVERYONE@:tcy
> root@radio:/testmnt# ./runas -k test314 ./test_access acltestjan3017/testacls/f.test301.test261.400.u+test314=5
> USER  999999314 (test314) 999999314 (test314) 999999314 (test314)
> GROUP 1427981 (user-test314) 1427981 (user-test314) 1427981 (user-test314)
> KRB5  test314@AD.BROWN.EDU
> SUPPL GROUPS: user-test314 
> r-- acltestjan3017/testacls/f.test301.test261.400.u+test314=5
> root@radio:/testmnt# ./runas -k test314 acltestjan3017/testacls/f.test301.test261.400.u+test314=5
> 
> My script "runas" su's and acquires kerberos credentials for the given
> user, and executes the given command.
> 
> My command test_access (a c program) prints all process credentials
> and then runs access(2) separately with R_OK, W_OK and X_OK modes,
> and prints the result.
> 
> The second line shows that access(2) indicates that user test314 has only
> read rights, despite the user ACE for test314.  The last line shows that
> test314 can, in fact, execute the file (which is empty - no error).
> 
> My client is a Debian Jessie system with these various versions of things:
> 
> Debian            8.6
> Kernel            3.16.0-4-amd64

I hate to say this, but I think there have been some relevant changes
since then, is it possible to retry with a more recent kernel?

Other things worth trying:

	- watch the traffic in wireshark, check that the ACCESS calls on
	  the wire agree with what your test program is seeing.
	- to verify that your server is mapping to the correct user, try
	  touching a new file after su'ing and acquiring kerberos
	  credentials, and check who the new file is owned by.

--b.

> acl               2.2.52-2
> libgssapi-krb5-2  1.12.1+dfsg-19+deb8u2
> librpcsecgss3     (not installed)
> nfs-utils         (? don't see it)
> util-linux        2.25.2-6
> 
> The server is an EMC Isilon.
> 
> John
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
