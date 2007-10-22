From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH] Fix logging segfaults on amd64
Date: Mon, 22 Oct 2007 09:47:03 -0400
Message-ID: <4d569c330710220647p70bd2a8qbafda75b95b1afd8@mail.gmail.com>
References: <20071021110257.GA24016@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjxcR-0006Yi-IJ
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 06:46:59 -0700
Received: from rv-out-0910.google.com ([209.85.198.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IjxcV-0006Ma-Ke
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 06:47:05 -0700
Received: by rv-out-0910.google.com with SMTP id g11so4060107rvb
	for <nfs@lists.sourceforge.net>; Mon, 22 Oct 2007 06:47:03 -0700 (PDT)
In-Reply-To: <20071021110257.GA24016@uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 10/21/07, Steinar H. Gunderson <sesse@debian.org> wrote:
> Hi,
>
> It seems an error crept into nfs-utils 1.1.1 just before release, so exportfs
> -r segfaults on amd64 whenever there is a warning. The attached patch, from
> Steve Langasek, fixes the issue (an abuse of va_list).

Thanks, I discovered this on Thursday and came up with the same
solution on Friday.  I was going to send it on today.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
