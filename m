Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6DCCC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:11:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7A5C12145D
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:11:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="W9eM9YWq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726891AbeLQPLo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 10:11:44 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:43536 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726637AbeLQPLo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 10:11:44 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBHF97nx095813;
        Mon, 17 Dec 2018 15:11:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=OPjgIw2tG722Ga6uqcHPxUC2ideR7gZbIWB10YqdfiM=;
 b=W9eM9YWqcXCTOcNE7wcZzXIdeiryJwVZx8o7b3zkUP2dIM+ME6h43+SRBsOOOb5C05kg
 emg6LTJ00fS9GlLkkjVbQ6WrTIDe90r76+aBBBP3pPu2VX7k1mopEq955gWYCcKEttkA
 8CGYzO/b5L2JAHYj8pg2sFrPT4eDtYu5Md0dX2z46igMF9nUB9L1bQuVwE4/HiA3UfRE
 fofpyfnzqnpjEjhJGakFx6vgxGvvKqLSv5IWMmbugtF33KNinjsDQNcR/1py5xTs7Y6A
 KWfSbp+lPN8sFlRFx5QhBnSgnK7GFaWj1gMky2ZQK7jhnNFjCiyPiWUav1EbpuiX9UkC +w== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2pct8qp2ge-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 15:11:38 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBHFBbDT015393
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 17 Dec 2018 15:11:38 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBHFBaGC010585;
        Mon, 17 Dec 2018 15:11:37 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 17 Dec 2018 07:11:36 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: mount option timeo - in deciseconds, or seconds?
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181215025034.j5zyfytvxqt35woz@mayhem.atnf.CSIRO.AU>
Date:   Mon, 17 Dec 2018 10:11:34 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <8EE078EE-CE10-4316-B447-F005B2034D69@oracle.com>
References: <20181215025034.j5zyfytvxqt35woz@mayhem.atnf.CSIRO.AU>
To:     Vincent McIntyre <vincent.mcintyre@csiro.au>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9110 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812170135
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Vincent-


> On Dec 14, 2018, at 9:50 PM, Vincent McIntyre =
<vincent.mcintyre@csiro.au> wrote:
>=20
> Hi,
>=20
> I've been trying to figure out why the nfs.man manpage states
>=20
>  .BI timeo=3D n
>  The time in deciseconds (tenths of a second) the NFS client waits for =
a
>  response before it retries an NFS request.
>=20
> Can someone who actually understands NFS enlighten me?
> Here's where I'm up to.
>=20
> I looked in the upstream git.
> The 'deciseconds' has been in there since the start of git history
> (2007, commit id 16db99b56a532bf56fa27618a6ef30763cd9006f).
> But is it (still) correct?
>=20
> Unfortunately I can't see a direct use of the 'timeo' field
> of the NFS data structure so the answer is not easily found.

The "timeo" mount option is not used by the mount.nfs command.
It is passed to the kernel, which treats it just as the man
page says.

The code you excerpt below implements the "retry" mount option.

.BI retry=3D n
The number of minutes that the
.BR mount (8)
command retries an NFS mount operation
in the foreground or background before giving up.
If this option is not specified, the default value for foreground mounts
is 2 minutes, and the default value for background mounts is 10000 =
minutes
(80 minutes shy of one week).
If a value of zero is specified, the
.BR mount (8)
command exits immediately after the first failure.
.IP
Note that this only affects how many retries are made and doesn't
affect the delay caused by each retry.  For UDP each retry takes the
time determined by the
.BR timeo
and
.BR retrans
options, which by default will be about 7 seconds.  For TCP the
default is 3 minutes, but system TCP connection timeouts will=20
sometimes limit the timeout of each retransmission to around 2 minutes.


> In utils/mount/nfsmount.c mountnfs() we have
>=20
> timeout =3D time(NULL) + 60 * retry;
>=20
> This sets the upper bound for how long to wait for a mount to succeed.
> The units are seconds, because retry is given in minutes.
>=20
> Also we see
>=20
> prevt =3D 0;
> t =3D 30;
> val =3D 1;
>=20
> these are the control variables for the loop
> The main check that prolongs the waiting time is
>=20
>            if (t - prevt < 30)
>                sleep(30);
>             ....if not mounted yet...
>            prevt =3D t;
>=20
> The decision to time out is made like this
>            t =3D time(NULL);
>            if (t >=3D timeout) {
>                rpc_mount_errors(*nfs_server.hostname, 0, bg);
>                goto fail;
>            }
>=20
> so it seems clear that t should also have the units of seconds.
> That also matches up with the declaration of t & timeout as time_t.
>=20
> But I still don't see how data.timo gets used.
> utils/mount/network.h defines this
>=20
>  static const struct timeval TIMEOUT =3D { 20, 0 };
> and
>  #define MOUNT_TIMEOUT   (30)
>=20
> which would seem to be in units of seconds,
> since eg. connect_to() uses seconds
> which reaches it via the calling path:
>=20
> 1.
> CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
> {
> ...
>    *msock =3D get_socket(mnt_saddr, mnt_pmap->pm_prot, MOUNT_TIMEOUT,
>                TRUE, FALSE);
>=20
> 2.
> static int get_socket(struct sockaddr_in *saddr, unsigned int p_prot,
>            unsigned int timeout, int resvp, int conn)
> {
> ...
>        cc =3D connect_to(so, SAFE_SOCKADDR(saddr), namelen,
>                timeout);
> 3.
> /*
> * Attempt to connect a socket, but time out after "timeout" seconds.
> *
> * On error return, caller closes the socket.
> */
> static int connect_to(int fd, struct sockaddr *addr,
>            socklen_t addrlen, int timeout)
> {
>=20
>=20
> Thanks
> Vince

--
Chuck Lever



