Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34024 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932354AbcBHSHl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2016 13:07:41 -0500
Received: by mail-oi0-f50.google.com with SMTP id j125so478021oih.1
        for <linux-nfs@vger.kernel.org>; Mon, 08 Feb 2016 10:07:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <A239ECE9-7327-40A0-BE48-F8DECA1914C9@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
	<1454706518-4641-7-git-send-email-andros@netapp.com>
	<CAHQdGtS1+yQp1bPEHYt9Po7GNe7Hv2O4dtRSae-fTsKySv1v0A@mail.gmail.com>
	<A239ECE9-7327-40A0-BE48-F8DECA1914C9@netapp.com>
Date: Mon, 8 Feb 2016 13:07:40 -0500
Message-ID: <CAHQdGtQAT9T-AanCuHA1JyndwO9jP_Bjcbq-usCnGohdtN1qyg@mail.gmail.com>
Subject: Re: [PATCH RFC Version 1 6/6] NFS schedule bind_conn_to_session for
 new NFSv4.1 transport
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 8, 2016 at 12:48 PM, Adamson, Andy
<William.Adamson@netapp.com> wrote:
>
>
> > On Feb 5, 2016, at 8:04 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> >
> > On Fri, Feb 5, 2016 at 4:08 PM,  <andros@netapp.com> wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> Complete session trunking with the BIND_CONN_TO_SESSION call.
> >> NFS cleanup after session trunking transport added
> >>
> >> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> ---
> >> fs/nfs/nfs4client.c | 13 +++++++++++--
> >> 1 file changed, 11 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> >> index 6736805..b0423f7 100644
> >> --- a/fs/nfs/nfs4client.c
> >> +++ b/fs/nfs/nfs4client.c
> >> @@ -423,8 +423,17 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
> >>                                .servername = clp->cl_hostname,
> >>                        };
> >>                        /* Add this address as an alias */
> >> -                       rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
> >> -                                       rpc_clnt_test_and_add_xprt, NULL);
> >> +                       error = rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
> >> +                                            rpc_clnt_test_and_add_xprt, NULL);
> >> +                       if (!error) {
> >> +                               nfs4_schedule_session_recovery(old->cl_session,
> >> +                                       -NFS4ERR_CONN_NOT_BOUND_TO_SESSION);
> >> +
> >> +                               /** Cancel the 2nd mount */
> >> +                               pr_info("NFS:  Session trunk. CANCEL MOUNT\n");
> >> +                               error = -EINVAL;
> >
> > You can't do this. What if we're not mounting the same path?
>
>
> This is the question I asked in the cover letter: Is using mount a good way to setup NFSv4.1 session trunking?
> How do you see session trunking being requested? Is mounting the export path on the server, but a different local mount point good enough?

The "standard" way of doing it is to supply multiple hostnames, in other words:

mount -t nfs foo,bar,baz:/export /mnt

We can then either supply the network addresses for foo, bar and baz
in the form of multiple 'addr=<address>' options (and possibly
prefixed by 'proto=<netid>' if necessary), or we could have the DNS
resolver do the translation for us.

Cheers
  Trond

>
> Thanks
>
> —>Andy
>
> >
> >> +                               goto error;
> >> +                       }
> >>                }
> >>                clp->cl_preserve_clid = true;
> >>        }
> >> --
> >> 1.8.3.1
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
