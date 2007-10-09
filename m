From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: Re: [RFC,PATCH 7/7] svc: Place type on same line for new API
Date: Tue, 9 Oct 2007 12:14:28 -0400
Message-ID: <e7ca40f70710090914h69e3ed89hdc4e68edb305b816@mail.gmail.com>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
	<20071009153722.18846.31423.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: "Tom Tucker" <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfHiy-0002uA-1u
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 09:14:34 -0700
Received: from wa-out-1112.google.com ([209.85.146.178])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfHj3-00086P-69
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 09:14:29 -0700
Received: by wa-out-1112.google.com with SMTP id k22so2223962waf
	for <nfs@lists.sourceforge.net>; Tue, 09 Oct 2007 09:14:28 -0700 (PDT)
In-Reply-To: <20071009153722.18846.31423.stgit@dell3.ogc.int>
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

New to list here, so I'll apologize in advance if this has already
been discussed...

On 10/9/07, Tom Tucker <tom@opengridcomputing.com> wrote:
>
> The convention is place the type name on the same line as the function
> name. The inline directive was also removed to allow the compiler to
> elect whether or not to inline.

The two versions of gcc that I checked do not attempt to decide
whether or not to inline without -O3.  Has the kernel tree started
using -O3?

-Aaron

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
