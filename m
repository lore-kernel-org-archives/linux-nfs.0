From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Update to the NFS Howto
Date: Fri, 14 Jul 2006 10:03:39 -0400
Message-ID: <4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com>
References: <4489840C0200006B0000515A@lucius.provo.novell.com>
	<2b585fc90606120403w755dfe76gb185ca135eed3732@mail.gmail.com>
	<2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>
	<44B7C69E.2C84.006B.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Christopher Smith <csmithere@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1OGc-0004Lo-Db
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 07:03:42 -0700
Received: from nf-out-0910.google.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1OGb-0006hh-BV
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 07:03:42 -0700
Received: by nf-out-0910.google.com with SMTP id g2so191919nfe
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 07:03:39 -0700 (PDT)
To: "Chakravarthi P" <pchakravarthi@novell.com>
In-Reply-To: <44B7C69E.2C84.006B.0@novell.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Some quick comments:

The following are more differences between suse and redhat:

suse                                 redhat
---------------------------             ------------------------------
/etc/init.d/nfsserver             /etc/init.d/nfs
/etc/init.d/gssd                   /etc/init.d/rpcgssd
/etc/init.d/svcgssd              /etc/init.d/rpcsvcgssd
/etc/init.d/idmapd               /etc/init.d/rpcidmapd

In /etc/sysconfig/nfs:

NFS_SECURITY_GSS       SECURE_NFS

Leaving off the path entirely in the /etc/gssapi_mech.conf file may be
a work-around for 32/64 compatibility:

# library                               initialization function
# =================      ==========================
# The MIT K5 gssapi library, use special function for initialization.
libgssapi_krb5.so                 mechglue_internal_krb5_init


The other idmapd mapping method is "umich_ldap", not "ldap_umich".

Thanks,
K.C.


On 7/14/06, Chakravarthi P <pchakravarthi@novell.com> wrote:
>
> Cms and all
>
>   there are 3 sections in the attached txt file for addressing 'howto'
> -
>   specific to nfsv4 and kerberos.
>   i have marked a $$$ whenever something mentioned is suse specfic
>   or if it is not specific to NFSv4 but NFS in general.
>   please get back with your comments.
>
> regards,
> chax.
>
>
>
>
> >>> On Mon, Jun 12, 2006 at  7:03 PM, in message
> <2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>,
> "Christopher
> Smith" <csmithere@gmail.com> wrote:
> > Chax--
> >
> > Thank you very much for what you have submitted.  A few comments:
> >
> > a) Some of the information tin the README is general to Linux, and
> > applies to all 2.6 implementations.
> > b) Some of the information here applies to SuSE specifically.
> > c) The Kerberos configuration section applies to both NFS Version 3
> as
> > well as NFS Version 4.
> >
> > What I would suggest is we do the following:
> >
> > * Break out the portions that apply specifically to NFS Version 4
> into
> > sections 3 and 4 of the HOWTO for server and client configuration.
> > * Break out the Kerberos documentation you've generated into a
> > subsection of the Security portion of the HOWTO, since it applies to
> > all NFS versions.
> > * Add notation where specific SuSE related configuration is
> required.
> >
> > Either you or I can do this.  Its up to you.
> >
> > Is this acceptable?
> >
> > Best,
> > CMS
> >
> >
>
>
>
>
>
>
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
>
>
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>
>
>


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
