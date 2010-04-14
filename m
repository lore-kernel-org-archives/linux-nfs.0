Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61352 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756590Ab0DNSv3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Apr 2010 14:51:29 -0400
Received: by gwaa18 with SMTP id a18so199113gwa.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 11:51:28 -0700 (PDT)
In-Reply-To: <1271270279.22566.22.camel@localhost.localdomain>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
	 <y2t4d569c331004141130z7525d001gcdb81db5b1ede42e@mail.gmail.com>
	 <1271270279.22566.22.camel@localhost.localdomain>
Date: Wed, 14 Apr 2010 14:51:22 -0400
Message-ID: <y2q4d569c331004141151n9042470aqe3f51e804b3abea9@mail.gmail.com>
Subject: Re: [PATCH 10/22] gss_krb5: Add upcall info indicating supported
	kerberos enctypes
From: Kevin Coffman <kwc@citi.umich.edu>
To: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 14, 2010 at 2:37 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2010-04-14 at 14:30 -0400, Kevin Coffman wrote:
>> On Wed, Apr 14, 2010 at 1:36 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > The text based upcall now indicates which Kerberos encryption types are
>> > supported by the kernel rpcsecgss code.  This is used by gssd to
>> > determine which encryption types it should attempt to negotiate
>> > when creating a context with a server.
>> >
>> > The server principal's database and keytab encryption types are
>> > what limits what it should negotiate.  Therefore, its keytab
>> > should be created with only the enctypes listed by this file.
>> >
>> > Currently we support des-cbc-crc, des-cbc-md4 and des-cbc-md5
>> >
>> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>> > ---
>> >  include/linux/sunrpc/gss_api.h      |    2 ++
>> >  net/sunrpc/auth_gss/auth_gss.c      |    8 +++++++-
>> >  net/sunrpc/auth_gss/gss_krb5_mech.c |    1 +
>> >  3 files changed, 10 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
>> > index 03f3333..b22d7f1 100644
>> > --- a/include/linux/sunrpc/gss_api.h
>> > +++ b/include/linux/sunrpc/gss_api.h
>> > @@ -80,6 +80,8 @@ struct gss_api_mech {
>> >        /* pseudoflavors supported by this mechanism: */
>> >        int                     gm_pf_num;
>> >        struct pf_desc *        gm_pfs;
>> > +       /* Should the following be a callback operation instead? */
>> > +       const char              *gm_upcall_enctypes;
>> >  };
>> >
>> >  /* and must provide the following operations: */
>> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
>> > index d64a58b..6654c85 100644
>> > --- a/net/sunrpc/auth_gss/auth_gss.c
>> > +++ b/net/sunrpc/auth_gss/auth_gss.c
>> > @@ -377,11 +377,12 @@ static void gss_encode_v0_msg(struct gss_upcall_msg *gss_msg)
>> >  static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
>> >                                struct rpc_clnt *clnt, int machine_cred)
>> >  {
>> > +       struct gss_api_mech *mech = gss_msg->auth->mech;
>> >        char *p = gss_msg->databuf;
>> >        int len = 0;
>> >
>> >        gss_msg->msg.len = sprintf(gss_msg->databuf, "mech=%s uid=%d ",
>> > -                                  gss_msg->auth->mech->gm_name,
>> > +                                  mech->gm_name,
>> >                                   gss_msg->uid);
>> >        p += gss_msg->msg.len;
>> >        if (clnt->cl_principal) {
>> > @@ -398,6 +399,11 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
>> >                p += len;
>> >                gss_msg->msg.len += len;
>> >        }
>> > +       if (mech->gm_upcall_enctypes) {
>> > +               len = sprintf(p, mech->gm_upcall_enctypes);
>> > +               p += len;
>> > +               gss_msg->msg.len += len;
>> > +       }
>> >        len = sprintf(p, "\n");
>> >        gss_msg->msg.len += len;
>> >
>> > diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> > index 8b612e7..d96d824 100644
>> > --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
>> > +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> > @@ -552,6 +552,7 @@ static struct gss_api_mech gss_kerberos_mech = {
>> >        .gm_ops         = &gss_kerberos_ops,
>> >        .gm_pf_num      = ARRAY_SIZE(gss_kerberos_pfs),
>> >        .gm_pfs         = gss_kerberos_pfs,
>> > +       .gm_upcall_enctypes = "enctypes=1,2,3 ",
>> >  };
>>
>> Hi Trond,
>> This list should be in preference order.  It doesn't matter much with
>> this one, but the preferred order for DES is usually "3,1,2".
>>
>> When adding 3DES, the list should be "16,3,1,2"
>> When adding AES, it should be "18,17,16,3,1,2"
>> When adding RC4, it should be "18,17,16,23,3,1,2"
>>
>> K.C.
>
> Hi Kevin,
>
> The decision to change the order was not mine. My first version of these
> patches did indeed preserve your ordering as above. However, apparently
> Steve's testing showed that the gss library routines prefer increasing
> order.
>
> More specifically, Steve identified that gss_set_allowable_enctypes()
> apparently requires ordering by increasing value.
>
> Cheers
>  Trond

Hi Steve,
This surprises me.  I believe this would result in DES being used
rather than the stronger enctypes.  Can you give me more details of
the problems you saw?

K.C.
