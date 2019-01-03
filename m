Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03F5EC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 20:54:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C12E9217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 20:54:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lESXGNmW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726519AbfACUyF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 15:54:05 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:46762 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726003AbfACUyF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 15:54:05 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03KmWUG143506;
        Thu, 3 Jan 2019 20:53:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=B0ogmQTZWnWXc9mmXwxCWmuv3QRsUcbGNlfCtMr8grE=;
 b=lESXGNmW75Ps1h4nov2UVqJtf0Sr6CGiZmAaq1ZyXZKhYxcl1mN0Tk0Wdkg10FFBJmXX
 i6IzssrClRqrVM1Q3MMUFJgkQsW1l9sLzm0wXJln/gGQpziU2TPArxlYg8QX9DQ7uJmK
 ItKkiOvzHLVyyWU8wJDaAqNtpQvHxHuocPw+7lxwIuqsA0oAnvg17oqo5peJ2tQtvzCJ
 fmQALwkLzUByV23wGXq+/mfLpf9kY3t0WyA7MTeGgDE0lT2/sonGZ2vV4+Ggl3V6d1rp
 GX1By4jWcWT66kIPM3MNqPkF5aZzvELW9OdiC6Z+yk/QsJIgfZScjK1rBLYc9MyOAcFP ng== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2130.oracle.com with ESMTP id 2pnxee9ba2-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 03 Jan 2019 20:53:59 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x03Krx5I029367
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 3 Jan 2019 20:53:59 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x03Krw7D008130;
        Thu, 3 Jan 2019 20:53:58 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 12:53:58 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
Date:   Thu, 3 Jan 2019 15:53:56 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <90B38E07-3241-4CCD-A4C8-AB78BADFB0CD@oracle.com>
References: <20190103182649.4148.19838.stgit@manet.1015granger.net>
 <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9125 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030180
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 3, 2019, at 1:47 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Thu, 2019-01-03 at 13:29 -0500, Chuck Lever wrote:
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index d5ce1a8..66b08aa 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -678,6 +678,31 @@ static void xs_stream_data_receive_workfn(struct
>> work_struct *work)
>>=20
>> #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
>>=20
>> +static int xs_send_record_marker(struct sock_xprt *transport,
>> +				 const struct rpc_rqst *req)
>> +{
>> +	static struct msghdr msg =3D {
>> +		.msg_name	=3D NULL,
>> +		.msg_namelen	=3D 0,
>> +		.msg_flags	=3D (XS_SENDMSG_FLAGS | MSG_MORE),
>> +	};
>> +	rpc_fraghdr marker;
>> +	struct kvec iov =3D {
>> +		.iov_base	=3D &marker,
>> +		.iov_len	=3D sizeof(marker),
>> +	};
>> +	u32 reclen;
>> +
>> +	if (unlikely(!transport->sock))
>> +		return -ENOTSOCK;
>> +	if (req->rq_bytes_sent)
>> +		return 0;
>=20
> The test needs to use transport->xmit.offset, not req->rq_bytes_sent.

OK, that seems to work better.


> You also need to update transport->xmit.offset on success,

That causes the first 4 bytes of the rq_snd_buf to not be sent.
Not updating xmit.offset seems more correct.


> and be
> prepared to handle the case where < sizeof(marker) bytes get
> transmitted due to a write_space condition.

Probably the only recourse is to break the connection.


>> +
>> +	reclen =3D req->rq_snd_buf.len;
>> +	marker =3D cpu_to_be32(RPC_LAST_STREAM_FRAGMENT | reclen);
>> +	return kernel_sendmsg(transport->sock, &msg, &iov, 1,
>> iov.iov_len);
>=20
>=20
> So what does this do for performance? I'd expect that adding another
> dive into the socket layer will come with penalties.

NFSv3 on TCP, sec=3Dsys, 56Gbs IBoIP, v4.20 + my v4.21 patches
fio, 8KB random, 70% read, 30% write, 16 threads, iodepth=3D16

Without this patch:

   read: IOPS=3D28.7k, BW=3D224MiB/s (235MB/s)(11.2GiB/51092msec)
  write: IOPS=3D12.3k, BW=3D96.3MiB/s (101MB/s)(4918MiB/51092msec)

With this patch:

   read: IOPS=3D28.6k, BW=3D224MiB/s (235MB/s)(11.2GiB/51276msec)
  write: IOPS=3D12.3k, BW=3D95.8MiB/s (100MB/s)(4914MiB/51276msec)

Seems like that's in the noise.


--
Chuck Lever



