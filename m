From: Stefan Walter <stefan.walter@inf.ethz.ch>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Thu, 02 Aug 2007 09:55:24 +0200
Message-ID: <46B18DEC.3030605@inf.ethz.ch>
References: <46ADDFB2.9070709@inf.ethz.ch>	<20070731144824.GA15231@fieldses.org>
	<20070731105941.61768945.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGVWn-0001LD-BO
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 00:55:25 -0700
Received: from xsmtp1.ethz.ch ([82.130.70.13])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGVWq-0005wa-LY
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 00:55:29 -0700
In-Reply-To: <20070731105941.61768945.jlayton@redhat.com>
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

Jeff Layton wrote:
> This issue with rpc.mountd crashing sounds familiar. It may be the same
> as RHBZ 242465 (which is unfortunately marked private so I can't really
> refer you to it). If it is the same, then there is a fix slated for
> inclusion in RHEL 4.6.
>
> If you have a non-critical place to do so, I'd suggest testing the
> RHEL4 nfs-utils packages available on my people page:
>
> http://people.redhat.com/jlayton
>
>   
I just downloaded and tried nfs-utils-1.0.6-81.EL4.i386.rpm but the included
rpc.mountd crashes the same way. I checked the source rpm on your
website and the relevant sections of the code (including the use of strcpy)
are the same as in the current RHEL4 nfs-utils source rpm.

BTW, I already opened a case with the Red Hat support (case 1736884).

- Stefan



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
