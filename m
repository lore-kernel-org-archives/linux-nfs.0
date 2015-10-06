Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-2.mit.edu ([18.9.25.13]:55542 "EHLO
	dmz-mailsec-scanner-2.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbbJFAHT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 20:07:19 -0400
Date: Mon, 5 Oct 2015 20:02:11 -0400 (EDT)
From: Benjamin Kaduk <kaduk@MIT.EDU>
To: "Adamson, Andy" <William.Adamson@netapp.com>
cc: Greg Hudson <ghudson@MIT.EDU>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "krbdev@mit.edu" <krbdev@MIT.EDU>
Subject: Re: Gss context refresh failure due to clock skew
In-Reply-To: <9ED9C3B6-A0D0-411F-AB95-77CB1E8AA097@netapp.com>
Message-ID: <alpine.GSO.1.10.1510051952080.26829@multics.mit.edu>
References: <AD03968E-7017-4D32-A90C-C74C1E9CDFAC@netapp.com> <FA7F806E-E5DA-4C41-AE7F-99E381E71123@netapp.com> <5612CB0F.5040501@mit.edu> <A7007DA3-24B2-4079-96A8-A6E97085031C@netapp.com> <5612D73F.8020605@mit.edu>
 <9ED9C3B6-A0D0-411F-AB95-77CB1E8AA097@netapp.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-559023410-442568504-1444089144=:26829"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---559023410-442568504-1444089144=:26829
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <alpine.GSO.1.10.1510051952571.26829@multics.mit.edu>

On Mon, 5 Oct 2015, Adamson, Andy wrote:

>
> > On Oct 5, 2015, at 4:02 PM, Greg Hudson <ghudson@MIT.EDU> wrote:
> >
> > On 10/05/2015 03:35 PM, Adamson, Andy wrote:
> >>> I think this case doesn't arise often because people don't often set
> >>> maximum service ticket lifetimes to be shorter than maximum TGT
> >>> lifetimes.
> >>
> >> Not the cause of the issue. The service ticket lifetime of 10 minutes =
is just there for testing this issue as I needed to wait until the service =
ticket had =E2=80=98expired=E2=80=99 on the server - but not yet on the cli=
ent.
> >>
> >> We see this issue all the time in NetApp QA as we run mutiple day heav=
y IO tests against a kerberos mount. If the server clock is ahead of the cl=
ient clock, permission denied errors stop the test as the first service tic=
ket =E2=80=9Cexpires=E2=80=9D on the server but not on the client.
> >
> > If the issue is not caused by short-lifetime service principals,
>
> I was wrong - you are right, it is caused by service ticket lifetimes bei=
ng shorter than TGT lifetimes.
>
> I didn=E2=80=99t know setting the service ticket lifetimes to not be less=
 than
> TGT lifetimes was a requirement. Neither does NetApp QA and I suspect,
> neither do customers in general.

It's not a requirement.  (Greg explicitly said "That said, your scenario
should work, and it doesn't." in his first message.)

> > then
> > the test scenario you described isn't representative of the real
> > scenario.  To reproduce the problem as it manifests in your IO tests,
> > you will need to adjust the TGT lifetime down to ten minutes as well as
> > the nfs/server lifetime.
>
> Code was added to rpc.gssd, the NFS client agent that creates GSS
> contexts for NFS, to take into account the clock skew and get a new TGT
> before (now+clock skew). So if the service ticket lifetime is equal to
> or greater than the TGT lifetime, then all is well.
>
> >
> >>> If the TGT itself has expired or is about to expire, some
> >>> out-of-band agent needs to refresh the TGT somehow, and it doesn't
> >>> matter all that much whether the failure comes from the client or the
> >>> server.
> >>
> >> I thought that having a keytab entry and a renewable TGT was enough.
> >
> > I'm not sure why you would do both of these; if you're getting initial
> > creds with a keytab, there is no need to muck around with ticket renewa=
l.
>
> I wouldn=E2=80=99t, but QA and customers do.
>
> >
> > Anyway, gss_init_sec_context() never renews tickets, and only gets
> > tickets from a keytab when a client keytab is configured (new in 1.11).
> > When tickets are obtained using a client keytab, they are refreshed
> > from the keytab when they are halfway to expiring,
>
> refreshed by=E2=80=A6?

The GSS library itself.
http://k5wiki.kerberos.org/wiki/Projects/Keytab_initiation and
http://web.mit.edu/kerberos/krb5-latest/doc/basic/keytab_def.html#default-c=
lient-keytab
give a little bit of intro, though this feature could benefit from better
documentation.

-Ben

> > so this clock skew
> > issue should not arise, so I don't think that feature is being used.
> >
> > It is possible that the NFS client code has its own separate logic for
> > obtaining new tickets using a keytab.
>
> When an NFS request requires a GSS context, if the context does not
> exist, is not valid, or if it is valid but the server replies to an RPC
> request using a GSS context with an RPC error that indicates it=E2=80=99s=
 side
> of the GSS context has a problem, the client kernel does an upcall to
> rpc.gssd which then decides if a new service ticket is required to send
> an RPCSEC_GSS_INIT message to the server to create a new GSS context.
> The resultant GSS context is stored in the client kernel with a lifetime
> equal to the service ticket used to create it.
>
> If rpc.gssd calls the code that refreshes the tickets from the keytab
> when they are half way to expiring=E2=80=99 then that should mitigate the=
 clock
> skew issue.
>
>
> > If so, we need to understand how
> > it works.  It's possible (though unlikely) that changing the behavior o=
f
> > gss_accept_sec_context() wouldn't be sufficient by itself.
>
>
> _______________________________________________
> krbdev mailing list             krbdev@mit.edu
> https://mailman.mit.edu/mailman/listinfo/krbdev
>
---559023410-442568504-1444089144=:26829--
