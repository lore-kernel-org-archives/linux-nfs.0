From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH_V4 1/9] SUNRPC new transport for the NFSv4.1 shared back channel
Date: Fri, 17 Dec 2010 15:11:18 -0500
Message-ID: <AANLkTin8HOuG=d+1n7HWzc3Vvti1-5zVbwwfMH-0nM6v@mail.gmail.com>
References: <1292610010-19084-1-git-send-email-andros@netapp.com>
	<1292610010-19084-2-git-send-email-andros@netapp.com>
	<20101217184047.GD11515@fieldses.org>
	<AANLkTinb3cZjPJZsGs-eNgU-5qMtvbFZMjY_rc=rZExN@mail.gmail.com>
	<AANLkTi=yKirVoRTEsz9s=8nQHPXR0C52DQHK-nz7Q82j@mail.gmail.com>
	<20101217191037.GA14510@fieldses.org>
	<AANLkTinjxeWAqW7p=nReP7jmqfWZi7CS_p+GVdno7zmQ@mail.gmail.com>
	<20101217193324.GC14510@fieldses.org>
	<AANLkTinHUSkV4LApqmwk+mU7OS5ro0u859PMtQ39qFPC@mail.gmail.com>
	<20101217200223.GE14510@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@netapp.com, bfields@redhat.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:59356 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752578Ab0LQULT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Dec 2010 15:11:19 -0500
Received: by iwn9 with SMTP id 9so1093859iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Dec 2010 12:11:19 -0800 (PST)
In-Reply-To: <20101217200223.GE14510@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 17, 2010 at 3:02 PM, J. Bruce Fields <bfields@fieldses.org>=
 wrote:
> On Fri, Dec 17, 2010 at 02:55:11PM -0500, William A. (Andy) Adamson w=
rote:
>> On Fri, Dec 17, 2010 at 2:33 PM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
>> > On Fri, Dec 17, 2010 at 02:16:35PM -0500, William A. (Andy) Adamso=
n wrote:
>> >> On Fri, Dec 17, 2010 at 2:10 PM, J. Bruce Fields <bfields@fieldse=
s.org> wrote:
>> >> > On Fri, Dec 17, 2010 at 01:57:50PM -0500, William A. (Andy) Ada=
mson wrote:
>> >> >> On Fri, Dec 17, 2010 at 1:54 PM, William A. (Andy) Adamson
>> >> >> <androsadamson@gmail.com> wrote:
>> >> >> > On Fri, Dec 17, 2010 at 1:40 PM, J. Bruce Fields <bfields@fi=
eldses.org> wrote:
>> >> >> >> On Fri, Dec 17, 2010 at 01:20:02PM -0500, andros@netapp.com=
 wrote:
>> >> >> >>> From: Andy Adamson <andros@netapp.com>
>> >> >> >>>
>> >> >> >>> Create a new transport for the shared back channel.l Move =
the current sock
>> >> >> >>> create and destroy routines into the new transport ops.
>> >> >> >>>
>> >> >> >>> Reference the back channel transport across message proces=
sing (recv/send).
>> >> >> >>>
>> >> >> >>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> >> >> >>> ---
>> >> >> >>> =A0include/linux/sunrpc/svcsock.h | =A0 =A01 +
>> >> >> >>> =A0net/sunrpc/svc.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 18 +=
++---
>> >> >> >>> =A0net/sunrpc/svcsock.c =A0 =A0 =A0 =A0 =A0 | =A0122 +++++=
++++++++++++++++++++++++++++-------
>> >> >> >>> =A03 files changed, 112 insertions(+), 29 deletions(-)
>> >> >> >>>
>> >> >> >>> diff --git a/include/linux/sunrpc/svcsock.h b/include/linu=
x/sunrpc/svcsock.h
>> >> >> >>> index 1b353a7..3a45a80 100644
>> >> >> >>> --- a/include/linux/sunrpc/svcsock.h
>> >> >> >>> +++ b/include/linux/sunrpc/svcsock.h
>> >> >> >>> @@ -45,6 +45,7 @@ int =A0 =A0 =A0 =A0 svc_sock_names(struc=
t svc_serv *serv, char *buf,
>> >> >> >>> =A0int =A0 =A0 =A0 =A0 =A0svc_addsock(struct svc_serv *ser=
v, const int fd,
>> >> >> >>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 char *name_return, const size_t len);
>> >> >> >>> =A0void =A0 =A0 =A0 =A0 svc_init_xprt_sock(void);
>> >> >> >>> +void =A0 =A0 =A0 =A0 svc_init_bc_xprt_sock(void);
>> >> >> >>> =A0void =A0 =A0 =A0 =A0 svc_cleanup_xprt_sock(void);
>> >> >> >>> =A0struct svc_xprt *svc_sock_create(struct svc_serv *serv,=
 int prot);
>> >> >> >>> =A0void =A0 =A0 =A0 =A0 svc_sock_destroy(struct svc_xprt *=
);
>> >> >> >>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> >> >> >>> index 6359c42..3520cb3 100644
>> >> >> >>> --- a/net/sunrpc/svc.c
>> >> >> >>> +++ b/net/sunrpc/svc.c
>> >> >> >>> @@ -488,10 +488,6 @@ svc_destroy(struct svc_serv *serv)
>> >> >> >>> =A0 =A0 =A0 if (svc_serv_is_pooled(serv))
>> >> >> >>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 svc_pool_map_put();
>> >> >> >>>
>> >> >> >>> -#if defined(CONFIG_NFS_V4_1)
>> >> >> >>> - =A0 =A0 svc_sock_destroy(serv->bc_xprt);
>> >> >> >>> -#endif /* CONFIG_NFS_V4_1 */
>> >> >> >>> -
>> >> >> >>> =A0 =A0 =A0 svc_unregister(serv);
>> >> >> >>> =A0 =A0 =A0 kfree(serv->sv_pools);
>> >> >> >>> =A0 =A0 =A0 kfree(serv);
>> >> >> >>> @@ -1264,7 +1260,7 @@ bc_svc_process(struct svc_serv *serv=
, struct rpc_rqst *req,
>> >> >> >>> =A0{
>> >> >> >>> =A0 =A0 =A0 struct kvec =A0 =A0 *argv =3D &rqstp->rq_arg.h=
ead[0];
>> >> >> >>> =A0 =A0 =A0 struct kvec =A0 =A0 *resv =3D &rqstp->rq_res.h=
ead[0];
>> >> >> >>> - =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 error;
>> >> >> >>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 ret;
>> >> >> >>>
>> >> >> >>> =A0 =A0 =A0 /* Build the svc_rqst used by the common proce=
ssing routine */
>> >> >> >>> =A0 =A0 =A0 rqstp->rq_xprt =3D serv->bc_xprt;
>> >> >> >>> @@ -1292,12 +1288,16 @@ bc_svc_process(struct svc_serv *se=
rv, struct rpc_rqst *req,
>> >> >> >>> =A0 =A0 =A0 svc_getu32(argv); =A0 =A0 =A0 /* XID */
>> >> >> >>> =A0 =A0 =A0 svc_getnl(argv); =A0 =A0 =A0 =A0/* CALLDIR */
>> >> >> >>>
>> >> >> >>> - =A0 =A0 error =3D svc_process_common(rqstp, argv, resv);
>> >> >> >>> - =A0 =A0 if (error <=3D 0)
>> >> >> >>> - =A0 =A0 =A0 =A0 =A0 =A0 return error;
>> >> >> >>> + =A0 =A0 /* Hold a reference to the back channel socket a=
cross the call */
>> >> >> >>> + =A0 =A0 svc_xprt_get(serv->bc_xprt);
>> >> >> >>
>> >> >> >> Either we already have a reference, in which case this is u=
nnecessary,
>> >> >> >> or we don't, in which case this is risky.
>> >> >> >
>> >> >> > This is done so that when svc_xprt_put is called due to an s=
vc_drop
>> >> >> > (svc_xprt_release, svc_xprt_put) it is not freed. =A0It's no=
t risky
>> >> >> > because AFAICS it's the way the rpc server code is intended =
to work.
>> >> >> > Note that svc_recv calls svc_xprt_get, and svc_send calls sv=
c_xprt_put
>> >> >> > for the same reason.
>> >> >
>> >> > The svc_xprt_put()'s in svc_send/svc_drop balance the get in sv=
c_recv().
>> >> > They're needed because on a normal server connections can come =
and go
>> >> > (because clients come and go) during the lifetime of the server=
=2E
>> >> >
>> >> > As I understand it, the client is just creating a new server fo=
r each
>> >> > backchannel. =A0So the server will never outlive the one connec=
tion it
>> >> > uses. =A0So you don't need that stuff. =A0It's harmless--just l=
eave it
>> >> > alone--but definitely don't try to add additional reference cou=
nting
>> >> > during the processing.
>> >>
>> >> If I don't add an svc_xprt_get prior to the svc_process_call, the
>> >> svc_xprt_put called in the svc_drop case will free the bc_xprt, w=
hich
>> >> is not what I want.
>> >
>> > Looking at the code some more.... =A0Oh, right, because the backch=
annel
>> > doesn't call svc_recv, it calls its own bc_send, which doesn't do =
a put.
>> >
>> > Oh, yuch, I see: svc_process_common returns "1" to mean send, "0" =
to
>> > mean drop, and leaves it up to the caller to do the put in the sen=
d
>> > case. =A0That's confusing.
>> >
>> > Maybe it would be simpler to have the caller be made responsible f=
or
>> > both cases? =A0So:
>> >
>> > =A0 =A0 =A0 =A0if (svc_process_common(rqstp))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0send it
>> > =A0 =A0 =A0 =A0else
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drop it
>>
>> That would work well. I'll send a patch
>
> If you do that you may want your own bc_svc_drop that doesn't bother
> with the put?
>
> You'd want to look through svc_xprt_release() to see if any of the re=
st
> of that makes sense in the bc case.

Yep :)

-->Andy
> --b.
>
