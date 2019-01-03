Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05790C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 22:49:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BE6BA21479
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 22:49:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5bBWCaj7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728261AbfACWth (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 17:49:37 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:55570 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726529AbfACWtg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 17:49:36 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03MnGvM040649;
        Thu, 3 Jan 2019 22:49:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=L8zVLUYgBq5sNKmV50I0qyyPoSnmiHM9gQ1nVdKlkKQ=;
 b=5bBWCaj7T13r7Ksf/mBrj90wtowCYlwlTybOqrtEnAeSAMJnpZNrJHQMOz/ZMbvmMWwB
 DK3KSAgye+VeiAMHu9tBCMQB3ZIsOWL5yb/U5NcF2k7f9k7czh0SYOrBbG8rDhIcfB6b
 WqASqoQCxZUr8TeiXQ0qSupdCLeBEWRzaotlYWSW1zOHfeS1ns2BHuPj1RIu8g4zvDac
 O4sux7lRZHqzCiS6j91uZZjDlqE2B+Vs12S2K8cImbb+mX4v439N0owXGU3RhCoUWkGz
 g9QBFfLPy8hmFa1UCaLwAijMGwjEIpIMSQls/LRXNX0BgVuQaQAR/3eEwy9ffkuHjsia IQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2pp1jr9h6m-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 03 Jan 2019 22:49:31 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x03MnTGo014722
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 3 Jan 2019 22:49:29 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x03MnRL5005383;
        Thu, 3 Jan 2019 22:49:29 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 14:49:27 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] SUNRPC: Remove rpc_xprt::tsh_size
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1353EAC5-5BEE-461E-A11E-31F00FC7B946@oracle.com>
Date:   Thu, 3 Jan 2019 17:49:26 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <CE340D31-4F14-4C6F-B7C8-958754394C08@oracle.com>
References: <20190103182649.4148.19838.stgit@manet.1015granger.net>
 <0331de80b8161f8bf16a92de20049cafb0c228da.camel@hammerspace.com>
 <90B38E07-3241-4CCD-A4C8-AB78BADFB0CD@oracle.com>
 <791EE189-59E5-4D58-9CF6-6D2CFC6C1210@oracle.com>
 <076cce85045dbaab3ca40947b2599f96cff66b53.camel@hammerspace.com>
 <1353EAC5-5BEE-461E-A11E-31F00FC7B946@oracle.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9125 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=806
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030193
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Jan 3, 2019, at 4:35 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
>> On Jan 3, 2019, at 4:28 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>>=20
>> On Thu, 2019-01-03 at 16:07 -0500, Chuck Lever wrote:
>>>> On Jan 3, 2019, at 3:53 PM, Chuck Lever <chuck.lever@oracle.com>
>>>> wrote:
>>>>=20
>>>>> On Jan 3, 2019, at 1:47 PM, Trond Myklebust <
>>>>> trondmy@hammerspace.com> wrote:
>>>>>=20
>>>>> On Thu, 2019-01-03 at 13:29 -0500, Chuck Lever wrote:
>>>>>> +	reclen =3D req->rq_snd_buf.len;
>>>>>> +	marker =3D cpu_to_be32(RPC_LAST_STREAM_FRAGMENT |
>>>>>> reclen);
>>>>>> +	return kernel_sendmsg(transport->sock, &msg, &iov, 1,
>>>>>> iov.iov_len);
>>>>>=20
>>>>> So what does this do for performance? I'd expect that adding
>>>>> another
>>>>> dive into the socket layer will come with penalties.
>>>>=20
>>>> NFSv3 on TCP, sec=3Dsys, 56Gbs IBoIP, v4.20 + my v4.21 patches
>>>> fio, 8KB random, 70% read, 30% write, 16 threads, iodepth=3D16
>>>>=20
>>>> Without this patch:
>>>>=20
>>>> read: IOPS=3D28.7k, BW=3D224MiB/s (235MB/s)(11.2GiB/51092msec)
>>>> write: IOPS=3D12.3k, BW=3D96.3MiB/s (101MB/s)(4918MiB/51092msec)
>>>>=20
>>>> With this patch:
>>>>=20
>>>> read: IOPS=3D28.6k, BW=3D224MiB/s (235MB/s)(11.2GiB/51276msec)
>>>> write: IOPS=3D12.3k, BW=3D95.8MiB/s (100MB/s)(4914MiB/51276msec)
>>>>=20
>>>> Seems like that's in the noise.
>>>=20
>>> Sigh. That's because it was the same kernel. Again, with feeling:
>>>=20
>>> 4.20.0-rc7-00048-g9274254:
>>>  read: IOPS=3D28.6k, BW=3D224MiB/s (235MB/s)(11.2GiB/51276msec)
>>> write: IOPS=3D12.3k, BW=3D95.8MiB/s (100MB/s)(4914MiB/51276msec)
>>>=20
>>> 4.20.0-rc7-00049-ga4dea15:
>>>  read: IOPS=3D27.2k, BW=3D212MiB/s (223MB/s)(11.2GiB/53979msec)
>>> write: IOPS=3D11.7k, BW=3D91.1MiB/s (95.5MB/s)(4917MiB/53979msec)
>>>=20
>>=20
>> So about a 5% reduction in performance?
>=20
> On this workload, yes.
>=20
> Could send the record marker in xs_send_kvec with the head[0] iovec.
> I'm going to try that next.

That helps:

Linux 4.20.0-rc7-00049-g664f679 #651 SMP Thu Jan 3 17:35:26 EST 2019

   read: IOPS=3D28.7k, BW=3D224MiB/s (235MB/s)(11.2GiB/51185msec)
  write: IOPS=3D12.3k, BW=3D96.1MiB/s (101MB/s)(4919MiB/51185msec)

--
Chuck Lever



