From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Re: Exportfs not showing exported file systems (was RE: stdio
	and nfs-utils)
Date: Thu, 26 Jul 2007 13:42:08 -0700
Message-ID: <01AE8AF878612047A442668306EAEB05D0219C@SACEXMV01.hq.netapp.com>
References: <20070725223723.GH7943@fieldses.org><20070726000700.GK7943@fieldses.org><18088.3581.647761.879253@notabene.brown><20070726031755.GB19901@fieldses.org><01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com>
	<20070726154806.ed0afdfd.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEAA4-0002r2-3M
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 13:42:16 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEAA7-0001OO-PX
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 13:42:20 -0700
In-Reply-To: <20070726154806.ed0afdfd.jlayton@redhat.com>
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

Any idea what one would need to change to verify if it's the same
problem?  Our base installs are almost all FC6 and RHEL 4/5 (begging the
question of whether it was fixed in RHEL 5 prior to release).  Someone
here can probably test on an FC7 system, but it would be really handy to
know how to fix the many existing installations, assuming it's the same
problem.

  Thanks,
  Dan

-----Original Message-----
From: Jeff Layton [mailto:jlayton@redhat.com] 
Sent: Thursday, July 26, 2007 12:48 PM
To: Muntz, Daniel
Cc: J. Bruce Fields; Neil Brown; nfs@lists.sourceforge.net
Subject: Re: [NFS] Exportfs not showing exported file systems (was RE:
stdio and nfs-utils)

On Thu, 26 Jul 2007 11:43:10 -0700
"Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:

> Could all this be related to a problem that we've been seeing while 
> working on v4/4.1 at netapp, where exportfs doesn't show any output 
> even when there are exported file systems?  Ricardo recently observed 
> that if you redirect the output of 'exportfs' then you actually do get

> the correct output (e.g., exportfs > afile, or exportfs | more).  This

> lead to some experiments with strace that show exportfs behaving 
> differently when its output is going to a tty.  We've seen this 
> behavior across a variety of kernels (2.6.18-2.6.20) and a variety of 
> nfs-utils (prepackaged with FC6, RHEL4/5, and built from a local copy
of 1.0.12).
> 

I saw a very similar problem with RHEL5 prior to its release. It turned
out to be a selinux policy issue. I believe the latest selinux-policy
packages in Fedora and RHEL have fixed it if it's the same problem.

--
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
