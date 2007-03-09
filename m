From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: RPCGSSD and root on Linux client
Date: Fri, 9 Mar 2007 11:14:05 -0500
Message-ID: <4d569c330703090814mae7f6b7hd494e89b5d46b77b@mail.gmail.com>
References: <01AE8AF878612047A442668306EAEB055C44F8@SACEXMV01.hq.netapp.com>
	<01AE8AF878612047A442668306EAEB055C4516@SACEXMV01.hq.netapp.com>
	<4d569c330703090724j2bcad85ayca0a383f9ec712f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Burlyga, Alex" <Alex.Burlyga@netapp.com>,
	nfs@lists.sourceforge.net
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPhjL-0002Ss-BT
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 08:14:07 -0800
Received: from ug-out-1314.google.com ([66.249.92.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPhjL-0008TK-B4
	for nfs@lists.sourceforge.net; Fri, 09 Mar 2007 08:14:09 -0800
Received: by ug-out-1314.google.com with SMTP id z38so1468763ugc
	for <nfs@lists.sourceforge.net>; Fri, 09 Mar 2007 08:14:06 -0800 (PST)
In-Reply-To: <4d569c330703090724j2bcad85ayca0a383f9ec712f1@mail.gmail.com>
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

After thinking about this a bit more, I have a concern.

Let's say root authenticates as "foo@REALM" and begins accessing NFS
files using those credentials.  Some time later, the context expires
or must be recreated for some reason and root's credentials cache is
now either expired or has been destroyed.  The initial context
creation will fail and we will fall back and use the machine
credentials to create the new context.  This will cause confusion
because all of the sudden root is "nfs/<machine>@REALM" rather than
"foo@REALM".

Any suggestions on a way around this?

K.C.

On 3/9/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
> Hi Dan,
> Thanks.  I think this sounds reasonable at first glance.  I'll try it out.
>
> There has also been interest in allowing the use of any usable key
> found in the keytab when using the machine credentials.  This would
> allow the use of a "host/<machine.name>@REALM" or
> "root/<machine.name>@REALM" key rather than requiring an
> "nfs/<machine.name>@REALM" key on the client.   I'll look into this as
> well.  (I have to look back at the spec to see if the callback channel
> authentication requires an nfs key on the client.  I don't think it
> does.)
>
> K.C.
>
> On 3/8/07, Muntz, Daniel <Dan.Muntz@netapp.com> wrote:
> > Original message and pseudo code logic are correct, but the patch is
> > broken.  Here's the new, slightly cleaner one (still for illustrative
> > purposes only :)
> >
> > --- gssd_proc.c.orig    2007-03-08 15:22:40.637927000 -0800
> > +++ gssd_proc.c 2007-03-08 16:50:08.104133000 -0800
> > @@ -675,6 +675,7 @@ handle_krb5_upcall(struct clnt_info *clp
> >         gss_buffer_desc         token;
> >         char                    **credlist = NULL;
> >         char                    **ccname;
> > +       int                     create_resp;
> >
> >         printerr(1, "handling krb5 upcall\n");
> >
> > @@ -688,7 +689,19 @@ handle_krb5_upcall(struct clnt_info *clp
> >                 goto out;
> >         }
> >
> > -       if (uid == 0) {
> > +       /* Tell krb5 gss which credentials cache to use */
> > +       gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
> > +
> > +       create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> > +                               AUTHTYPE_KRB5);
> > +       if (create_resp != 0 && uid != 0) {
> > +               printerr(0, "WARNING: Failed to create krb5 context "
> > +                   "for user with uid %d for server %s\n",
> > +                        uid, clp->servername);
> > +               goto out_return_error;
> > +       }
> > +
> > +       if (create_resp != 0 && uid == 0) {
> >                 int success = 0;
> >
> >                 /*
> > @@ -723,18 +736,6 @@ handle_krb5_upcall(struct clnt_info *clp
> >                         goto out_return_error;
> >                 }
> >         }
> > -       else {
> > -               /* Tell krb5 gss which credentials cache to use */
> > -               gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
> > -
> > -               if ((create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
> > -                                                       AUTHTYPE_KRB5))
> > != 0) {
> > -                       printerr(0, "WARNING: Failed to create krb5
> > context "
> > -                                   "for user with uid %d for server
> > %s\n",
> > -                                uid, clp->servername);
> > -                       goto out_return_error;
> > -               }
> > -       }
> >
> >         if (!authgss_get_private_data(auth, &pd)) {
> >                 printerr(0, "WARNING: Failed to obtain authentication "
> >
> >
> >
> > -----Original Message-----
> > From: Muntz, Daniel
> > Sent: Thursday, March 08, 2007 3:59 PM
> > To: nfs@lists.sourceforge.net
> > Cc: Burlyga, Alex
> > Subject: [NFS] RPCGSSD and root on Linux client
> >
> > We've hit the following issue with root and Kerberos on the linux
> > client:
> >
> > > I run in into interesting problem with recent change to rpcgssd on the
> >
> > > linux client.
> > > The change itself made -m flag mandatory, meaning that for user uid =
> > > 0 , different principal will be used, namely first principal specified
> >
> > > in /etc/krb5.keytab which starts with nfs. From the filer perspective
> > > after that change there is no way root will come in as a principal
> > > over RPCSEC_GSS so, for example, root can't create a file with root as
> >
> > > owner. I'm not sure how Linux nfs server handles this, but behavior
> > > seems broken. Do you know what was the rationale behind this change?
> > > am I missing something?
> >
> > Our guess at what's going on here is that gssd was changed so that
> > initial mounts and the automounter could acquire a cred even when there
> > is no root cred available on the machine.  Unfortunately, the change to
> > gssd maps all uid=0 requests to a non-root principal.  Currently the
> > code does something like this:
> >
> >   if (uid == 0)
> >         map some non-root principal to uid 0
> >   else
> >       do normal uid->principal mapping
> >
> > I'm suggesting chaging this logic to:
> >
> >   do normal uid->principal mapping
> >   if mapping failed && uid == 0
> >         map some non-root principal to uid 0 (as in the original case)
> >
> > So, if we have a root cred hanging around (e.g., in krb5.keytab, via
> > kinit, etc.), we go ahead and use it.  Otherwise, we use the existing
> > code to map uid 0 to some other principal.  In either case, automount,
> > mounts during startup, etc. should be happy, but we're still able to use
> > the root principal.
> >
> > Patch below is **untested** but illustrates the proposed change.
> >
> > We need to know if we've missed something in the reasoning for the
> > original change that impacts the proposed solution.  Or if the proposal
> > is flawed in some other respect :-)
> >
> >   -Dan
> >
> > -------------------------------------------------------------------------
> > Take Surveys. Earn Cash. Influence the Future of IT
> > Join SourceForge.net's Techsay panel and you'll get the chance to share your
> > opinions on IT & business topics through brief surveys-and earn cash
> > http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
>

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
