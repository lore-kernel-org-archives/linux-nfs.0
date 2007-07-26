From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Re: Exportfs not showing exported file systems (was RE: stdio
	and nfs-utils)
Date: Thu, 26 Jul 2007 14:40:15 -0700
Message-ID: <01AE8AF878612047A442668306EAEB05D021C8@SACEXMV01.hq.netapp.com>
References: <20070725223723.GH7943@fieldses.org><20070726000700.GK7943@fieldses.org><18088.3581.647761.879253@notabene.brown><20070726031755.GB19901@fieldses.org><01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com><20070726154806.ed0afdfd.jlayton@redhat.com><01AE8AF878612047A442668306EAEB05D0219C@SACEXMV01.hq.netapp.com>
	<20070726171209.6fbccdd3.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEB4L-0000mR-0Y
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 14:40:25 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEB4O-0002gk-RK
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 14:40:29 -0700
In-Reply-To: <20070726171209.6fbccdd3.jlayton@redhat.com>
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

Yep, disabling selinux fixed it on my FC6 machine.

  -Dan 

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com] 
> Sent: Thursday, July 26, 2007 2:12 PM
> To: Muntz, Daniel
> Cc: J. Bruce Fields; Neil Brown; nfs@lists.sourceforge.net
> Subject: Re: [NFS] Exportfs not showing exported file systems 
> (was RE: stdio and nfs-utils)
> 
> On Thu, 26 Jul 2007 13:42:08 -0700
> "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
> 
> > Any idea what one would need to change to verify if it's the same
> > problem?  Our base installs are almost all FC6 and RHEL 4/5 
> (begging the
> > question of whether it was fixed in RHEL 5 prior to 
> release).  Someone
> > here can probably test on an FC7 system, but it would be 
> really handy to
> > know how to fix the many existing installations, assuming 
> it's the same
> > problem.
> > 
> >   Thanks,
> >   Dan
> > 
> 
> While it's discouraged for us to suggest, you could do what I did and
> temporarily put selinux in permissive mode: ;-)
> 
> # setenforce 0
> 
> ...and then see if exportfs still has the issue. To turn it back to
> enforcing do:
> 
> # setenforce 1
> 
> I've not been able to reproduce the problem since it was reportedly
> fixed. The BZ I opened on it is here:
> 
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=221181
> 
> ...if you find that selinux is at fault then you may want to 
> reopen it.
> It might also be worthwhile to do the same with Bruce's original
> problem and see if it behaves any differently.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
