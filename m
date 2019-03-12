Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33256C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 18:54:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F4145206BA
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 18:54:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="YRDoDAbv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726400AbfCLSya (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 14:54:30 -0400
Received: from aserp2130.oracle.com ([141.146.126.79]:57864 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726339AbfCLSya (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2019 14:54:30 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2CIrmYb054155;
        Tue, 12 Mar 2019 18:54:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=RPuLe3g63hc3kJlYviOk9UYQXykOKzWaoC6gdGHJ9us=;
 b=YRDoDAbvUR9DWNjVN0XGj3PXtArC+QPO0xWQbqMZvycsqOrP+L9t27D9ikQeEZayaATq
 nTsN9Mp9eUUbI6m4UveGFYYCtHbS2beB3Zf44uoZztFm2GICxfV+WlO8kvQCGDA7vgnN
 FqMsOvoAvxBJwpYqxZ5QmrJH6AtdVrnztSmh4LM11J5trQM12rFaXC4ugIVTV72Fvllu
 DQ+pQmK30UeybAsPIiynTUZqUoJc4IvLjq05ObuIlWn70elbjEaKamhOLMyzPzEDOdhs
 n/8jPpe5JQ2DedStpnzfBtynA8IZ+EXc92D1BFfB8rxha5Xn+JuWM3nbZwNYoq3OsBAQ wA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2r430eq59v-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 12 Mar 2019 18:54:22 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2CIsMuk004291
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 12 Mar 2019 18:54:22 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2CIsL6m001884;
        Tue, 12 Mar 2019 18:54:22 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 12 Mar 2019 18:54:21 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: oops on a sunrpc tracepoint
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <277d2273a5e6c34a5898fab7dd6b019e43968a40.camel@hammerspace.com>
Date:   Tue, 12 Mar 2019 14:54:20 -0400
Cc:     Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <08FD3CD9-BED8-4D76-8FF5-EBFC0A5A7AA2@oracle.com>
References: <CAN-5tyFt0j9g4iTzoT-HqzKLDvMqq+x1=PxWPBHzAd3seyaqcQ@mail.gmail.com>
 <69C7D007-BA4A-4711-8024-57B26F5BAE5E@oracle.com>
 <CAN-5tyED+23WxH3z_yoEGaRaica8DMhKaO+pYOstbU7P=Y6whg@mail.gmail.com>
 <959FF86E-32E0-45CA-A05A-0AEAF8F802B4@oracle.com>
 <277d2273a5e6c34a5898fab7dd6b019e43968a40.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9193 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903120128
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 12, 2019, at 2:41 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Tue, 2019-03-12 at 10:47 -0400, Chuck Lever wrote:
>>> On Mar 12, 2019, at 10:36 AM, Olga Kornievskaia <aglo@umich.edu>
>>> wrote:
>>>=20
>>> On Tue, Mar 12, 2019 at 10:33 AM Chuck Lever <
>>> chuck.lever@oracle.com> wrote:
>>>>=20
>>>>=20
>>>>> On Mar 12, 2019, at 10:29 AM, Olga Kornievskaia <aglo@umich.edu
>>>>>> wrote:
>>>>>=20
>>>>> Hi Chuck,
>>>>>=20
>>>>> Is this a known issue?
>>>>=20
>>>> Nope.
>>>=20
>>> Ok.
>>> Looks like anything to do with callback channeling trying to use
>>> the
>>> trace_event_raw_event_xprt_transmit....
>>=20
>> Callback rqst's are missing either an rq_task or rq_task->tk_client
>> (I can't remember at the moment). It would be nicer for the forward
>> channel infrastructure if such rqst's were complete...
>>=20
>> Otherwise, trace_xprt_transmit and trace_xprt_enq_xmit need to check
>> if task and task->tk_client are present before dereferencing them.
>=20
> Back channel tasks have no associated task->tk_client. They are owned
> by a server task, not by a client.

Understood, I'm simply suggesting that there could be a "phony"
client for callbacks so that other code doesn't have to check to
see if tk_client is populated before dereferencing it.


> In either case, the transport code should avoid concerning itself with
> the client structure. That's a higher layer object.

Right. The only reason the transport is concerning itself with
tk_client is the task:%u@%u identifier in trace points.

I would think that, for instance, someone adding an ad hoc kprobe
would want to avoid a fault here, but would have to know that
callback rqst's passing through the forward channel code do not
have a tk_client.


--
Chuck Lever



