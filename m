From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Clarify language in man exportfs
Date: Sat, 03 Nov 2007 09:18:10 -0400
Message-ID: <472C7512.1090101@RedHat.com>
References: <20071029180443.GA6109@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IoIwX-0004zO-7y
	for nfs@lists.sourceforge.net; Sat, 03 Nov 2007 06:21:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IoIwa-0008Gg-3S
	for nfs@lists.sourceforge.net; Sat, 03 Nov 2007 06:21:45 -0700
In-Reply-To: <20071029180443.GA6109@uio.no>
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



Steinar H. Gunderson wrote:
> (I still have two pending minor patches, by the way :-) )
> 
> As discussed in a user case earlier, the wording in the exportfs man page can
> be a bit confusing, implying that "exportfs -u :/foo" will unexport /foo from
> all hosts, which it won't. Thus, make the language clearer -- based on
> suggestion/patch from David Liontooth.
> 
> Signed-off-by: Steinar H. Gunderson <sesse@debian.org>
Committed.

Also added some examples on how to unexport directories.

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
