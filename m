Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D4F9C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:22:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1F65020855
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:22:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="AvOviBL2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727165AbfDDPWp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 11:22:45 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:52200 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726952AbfDDPWp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2019 11:22:45 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34F915u030159;
        Thu, 4 Apr 2019 15:22:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=NXoO+XYw4ofnP2dcLEZ6tblgbH8ukWbPkQw9xt82IiU=;
 b=AvOviBL2Y3K0hXGeo8P3mhJYl81wcGFcOM0AW8vk6DM3hlw+cFVS0j9y0Q80Zy94GpGN
 7h/tFDErkCcTHyAB5q81MsT+SpqOJDrOVCwE7O2e6tdFzLOb6CWAYtG4yYBNfgvWGsH/
 kDxUDngdkhQlGl1rZEfHVrAhgy8YPntn/wqzzcs5ghZ7gxVvFLDRcGbXxhqcah9tp1q8
 g+i/n2/6IiF+3ZjxxVKsn2gVpTx1gyxK+ol027eUVwZq/nyioDEQUeXAhL4ryHndyxWj
 v3UBn32fpfn6MRn3Hq7MoZ1rdahnC/3TdhC22lKOuUNfaoHoVBy+GlrZvtTCRVOD5iWE 3g== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
        by userp2130.oracle.com with ESMTP id 2rhyvtfuw8-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 04 Apr 2019 15:22:37 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
        by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34FLM1X163834;
        Thu, 4 Apr 2019 15:22:36 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserp3030.oracle.com with ESMTP id 2rm8f605wr-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 04 Apr 2019 15:22:36 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x34FMaO7023991;
        Thu, 4 Apr 2019 15:22:36 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 04 Apr 2019 08:22:36 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: directory delegations
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
Date:   Thu, 4 Apr 2019 11:22:34 -0400
Cc:     Bruce Fields <bfields@fieldses.org>,
        "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <97542732-49F5-4BEA-9903-D9801370A221@oracle.com>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org>
 <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org>
 <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org>
 <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
 <20190404010559.GA17840@fieldses.org>
 <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
To:     Jeff Layton <jlayton@poochiereds.net>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040098
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040098
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Apr 4, 2019, at 11:09 AM, Jeff Layton <jlayton@poochiereds.net> =
wrote:
>=20
> On Wed, Apr 3, 2019 at 9:06 PM bfields@fieldses.org
> <bfields@fieldses.org> wrote:
>>=20
>> On Wed, Apr 03, 2019 at 12:56:24PM -0400, Bradley C. Kuszmaul wrote:
>>> This proposal does look like it would be helpful.   How does this
>>> kind of proposal play out in terms of actually seeing the light of
>>> day in deployed systems?
>>=20
>> We need some people to commit to implementing it.
>>=20
>> We have 2-3 testing events a year, so ideally we'd agree to show up =
with
>> implementations at one of those to test and hash out any issues.
>>=20
>> We revise the draft based on any experience or feedback we get.  If
>> nothing else, it looks like it needs some updates for v4.2.
>>=20
>> The on-the-wire protocol change seems small, and my feeling is that =
if
>> there's running code then documenting the protocol and getting it
>> through the IETF process shouldn't be a big deal.
>>=20
>> --b.
>>=20
>>> On 4/2/19 10:07 PM, bfields@fieldses.org wrote:
>>>> On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
>>>>> The create itself needs to be sync, but the attribute delegations =
mean
>>>>> that the client, not the server, is authoritative for the =
timestamps.
>>>>> So the client now owns the atime and mtime, and just sets them as =
part
>>>>> of the (asynchronous) delegreturn some time after you are done =
writing.
>>>>>=20
>>>>> Were you perhaps thinking about this earlier proposal?
>>>>> =
https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__tools.ietf.org_html=
_draft-2Dmyklebust-2Dnfsv4-2Dunstable-2Dfile-2Dcreation-2D01&d=3DDwIBAg&c=3D=
RoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=3DYIKOmJLMLfe5wQR3VJI7jGjCne=
pZlMwumApzvaKItrY&m=3DqlAJ6dZPGjbcTzNIpkTyk-RTii6lWw1CLIjF6jp3P2Y&s=3DaTTF=
NJlRH-dXrQmE4cSYEUd8Kv3ij5cqTJtvgIixMa8&e=3D
>>>> That's it, thanks!
>>>>=20
>>>> Bradley is concerned about performance of something like untar on a
>>>> backend filesystem with particularly high-latency metadata =
operations,
>>>> so something like your unstable file createion proposal (or actual =
write
>>>> delegations) seems like it should help.
>>>>=20
>>>> --b.
>=20
> The serialized create with something like an untar is a
> performance-killer though.
>=20
> FWIW, I'm working on something similar right now for Ceph. If a ceph
> client has adequate caps [1] for a directory and the dentry inode,
> then we should (in principle) be able to buffer up directory morphing
> operations and flush them out to the server asynchronously.
>=20
> I'm starting with unlink (mostly because it's simpler), and am mainly
> just returning early when we do have the right caps -- after issuing
> the call but before the reply comes in. We should be able to do the
> same for link, rename and create too. Create will require the Ceph MDS
> to delegate out a range of inode numbers (and that bit hasn't been
> implemented yet).
>=20
> My thinking with all of this is that the buffering of directory
> morphing operations is not as helpful as something like a pagecache
> write is, as we aren't that interested in merging operations that
> change the same dentry. However, being able to do them asynchronously
> should work really well. That should allow us to better parallellize
> create/link/unlink/rename on different dentries even when they are
> issued serially by a single task.

What happens if an asynchronous directory change fails (eg. ENOSPC)?


> RFC5661 doesn't currently provide for writeable directory delegations,
> AFAICT, but they could eventually be implemented in a similar way.
>=20
> [1]: cephfs capabilies (aka caps) are like a delegation for a subset
> of inode metadata
> --
> Jeff Layton <jlayton@poochiereds.net>

--
Chuck Lever



