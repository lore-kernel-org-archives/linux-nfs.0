Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9104C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:55:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78BF620665
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:55:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="odJlzxjh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726180AbfBSOzA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 09:55:00 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:41978 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725885AbfBSOzA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 09:55:00 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1JEsSUC196279;
        Tue, 19 Feb 2019 14:54:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=XmR8oWiAzZE4CX6Hc8HvILv5HF06U04QfKjz6RwPWLQ=;
 b=odJlzxjhMYiUUeoNvIPUDu6aTY7tNiC6Y6me6dOCiIhoXC/wilJtCHEJN+tXBp/TTKml
 eyCCQaYnMYqCzypNBgDm4tBQGefi62jH6fJ0pl+qNeTzlJ23HGXLgZV28tgX987fjxbP
 DThEWCHQs2sb8dMcUvXh6TdWI6cEgeC3EL4FEysJgcMTLN/o/Zb0njC1gOuC0T3TDbgK
 //lgWgaSzlSJ9r5wHPQRLCC+lUSOFpS1yTCmmMcc/KaS5jiHucj7heD09jvcymx0wmtC
 qZyvdhZeE/z5QzabqPhqqyApIc4gZaNyUbN7wKFQXgcflfBpETEb/fnpjFJOZp+IGB4/ vw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2qp81e3trh-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 14:54:57 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1JEsuw2006517
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 14:54:57 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1JEsuSC025535;
        Tue, 19 Feb 2019 14:54:56 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 19 Feb 2019 06:54:56 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] SUNRPC: Use poll() to fix up the socket requeue races
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190219140616.123141-1-trond.myklebust@hammerspace.com>
Date:   Tue, 19 Feb 2019 09:54:55 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A2BBC175-F60D-4C61-B70F-479952D2CD21@oracle.com>
References: <20190219140616.123141-1-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9171 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902190112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond-

> On Feb 19, 2019, at 9:06 AM, Trond Myklebust <trondmy@gmail.com> =
wrote:
>=20
> Because we clear XPRT_SOCK_DATA_READY before reading, we can end up
> with a situation where new data arrives, causing xs_data_ready() to
> queue up a second receive worker job for the same socket, which then
> immediately gets stuck waiting on the transport receive mutex.
> The fix is to only clear XPRT_SOCK_DATA_READY once we're done reading,
> and then to use poll() to check if we might need to queue up a new
> job in order to deal with any new data.

Does this fix an application-visible hang, or is it merely a performance
optimization?


> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
> net/sunrpc/xprtsock.c | 17 +++++++++++++++--
> 1 file changed, 15 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index f5d7dcd9e8d9..a721c843d5d3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -656,13 +656,25 @@ xs_read_stream(struct sock_xprt *transport, int =
flags)
> 	return ret !=3D 0 ? ret : -ESHUTDOWN;
> }
>=20
> +static void xs_poll_check_readable(struct sock_xprt *transport)
> +{
> +	struct socket *sock =3D transport->sock;
> +	__poll_t events;
> +
> +	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
> +	events =3D sock->ops->poll(NULL, sock, NULL);
> +	if (!(events & (EPOLLIN | EPOLLRDNORM)) || events & EPOLLRDHUP)
> +		return;
> +	if (!test_and_set_bit(XPRT_SOCK_DATA_READY, =
&transport->sock_state))
> +		queue_work(xprtiod_workqueue, &transport->recv_worker);
> +}
> +
> static void xs_stream_data_receive(struct sock_xprt *transport)
> {
> 	size_t read =3D 0;
> 	ssize_t ret =3D 0;
>=20
> 	mutex_lock(&transport->recv_mutex);
> -	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
> 	if (transport->sock =3D=3D NULL)
> 		goto out;
> 	for (;;) {
> @@ -672,6 +684,7 @@ static void xs_stream_data_receive(struct =
sock_xprt *transport)
> 		read +=3D ret;
> 		cond_resched();
> 	}
> +	xs_poll_check_readable(transport);
> out:
> 	mutex_unlock(&transport->recv_mutex);
> 	trace_xs_stream_read_data(&transport->xprt, ret, read);
> @@ -1362,7 +1375,6 @@ static void xs_udp_data_receive(struct sock_xprt =
*transport)
> 	int err;
>=20
> 	mutex_lock(&transport->recv_mutex);
> -	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
> 	sk =3D transport->inet;
> 	if (sk =3D=3D NULL)
> 		goto out;
> @@ -1374,6 +1386,7 @@ static void xs_udp_data_receive(struct sock_xprt =
*transport)
> 		consume_skb(skb);
> 		cond_resched();
> 	}
> +	xs_poll_check_readable(transport);
> out:
> 	mutex_unlock(&transport->recv_mutex);
> }
> --=20
> 2.20.1
>=20

--
Chuck Lever



