Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9074C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 20:45:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78CF7206C0
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 20:45:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jVwH/tJ5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731191AbfDDUp1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 16:45:27 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:53842 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730337AbfDDUp0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2019 16:45:26 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34KiDHZ138399;
        Thu, 4 Apr 2019 20:45:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=RCuujwfQx/pMXmC8BCxqoY65etIOaX6mmA93sG+Xe0A=;
 b=jVwH/tJ5uvnKiq0QQ6LCkS8sau1AdDr7SDpMIJFOjq89da2FNrP0vfrKWQCjaq1vFNcw
 4UepvXjugHxiQHEeWBpcqX+ORDdtOFYoCAt7/GwZSeBB7OXwBIpILyQhYnE2F86P9amt
 CsI4+PlUijwujvMngc4ZwMPWWUo2egCxon35ooxUX2MfYF9bj4HMHbHlFGqzp+AWGTVG
 s8avdRiBjEfo6/4pW0CHbwUXNYPVYwJsins50G6nNeRc9Wn2AGO7J3Mf0qbgiuZVS/Qy
 geb/1wDTBXP1PnMgp/rzSEj1tK9Jr2wpA0buu9EKhtEi4KfqRvCC795xy1oipcqzOpmy ig== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
        by userp2120.oracle.com with ESMTP id 2rj13qhf87-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 04 Apr 2019 20:45:21 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
        by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34KhiJI155670;
        Thu, 4 Apr 2019 20:45:20 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userp3020.oracle.com with ESMTP id 2rm8f6w2w0-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 04 Apr 2019 20:45:20 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x34KjJkw031426;
        Thu, 4 Apr 2019 20:45:19 GMT
Received: from bradley.us.oracle.com (/10.152.12.111)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 04 Apr 2019 13:45:19 -0700
Subject: Re: directory delegations
To:     Bruce Fields <bfields@fieldses.org>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20190402194148.GA5269@fieldses.org>
 <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org>
 <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org>
 <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
 <20190404010559.GA17840@fieldses.org>
 <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
 <97542732-49F5-4BEA-9903-D9801370A221@oracle.com>
 <9ca6e116-818b-6615-1532-47611b6fcc6f@oracle.com>
 <20190404204116.GA27839@fieldses.org>
From:   "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Message-ID: <380b012e-d3b8-fcb1-e673-e25a1da4a0ac@oracle.com>
Date:   Thu, 4 Apr 2019 16:45:13 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190404204116.GA27839@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040131
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040131
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Yes, maybe it's not important.

-Bradley

On 4/4/19 4:41 PM, Bruce Fields wrote:
> On Thu, Apr 04, 2019 at 04:03:42PM -0400, Bradley C. Kuszmaul wrote:
>> It would also be possible with our file system to preallocate inode
>> numbers (inumbers).
>>
>> This isn't necessarily directly related to NFS, but one could
>> imagine further extending NSF to allow a CREATE to happen entirely
>> on the client by letting the client maintain a cache of preallocated
>> inumbers.
> So, we'd need new protocol to allow clients to request inode numbers,
> and I guess we'd also need vfs interfaces to allow our server to request
> them from various filesystems.  Naively, it sounds doable.  From what
> Jeff says, this isn't a requirement for correctness, it's an
> optimization for a case when the client creates and then immediately
> does a stat (or readdir?).  Is that important?
>
> --b.
>
>> Just for the fun of it, I'll tell you a little bit more about how we
>> preallocate inumbers.
>>
>> For Oracle's File Storage Service (FSS), Inumbers are cheap to
>> allocate, and it's not a big deal if a few of them end up unused.
>> Unused inode numbers don't use up any space. I would imagine that
>> most B-tree-based file systems are like this.   In contrast in an
>> ext-style file system, unused inumbers imply unused storage.
>>
>> Furthermore, FSS never reuses inumbers when files are deleted. It
>> just keeps allocating new ones.
>>
>> There's a tradeoff between preallocating lots of inumbers to get
>> better performance but potentially wasting the inumbers if the
>> client were to crash just after getting a batch.   If you only ask
>> for one at a time, you don't get much performance, but if you ask
>> for 1000 at a time, there's a chance that the client could start,
>> ask for 1000 and then immediately crash, and then repeat the cycle,
>> quickly using up many inumbers.  Here's a 2-competetive algorithm to
>> solve this problem (by "2-competetive" I mean that it's guaranteed
>> to waste at most half of the inode numbers):
>>
>>   * A client that has successfully created K files without crashing
>> is allowed, when it's preallocated cache of inumbers goes empty, to
>> ask for another K inumbers.
>>
>> The worst-case lossage occurs if the client crashes just after
>> getting K inumbers, and those inumbers go to waste.   But we know
>> that the client successfully created K files, so we are wasting at
>> most half the inumbers.
>>
>> For a long-running client, each time it asks for another batch of
>> inumbers, it doubles the size of the request.  For the first file
>> created, it does it the old-fashioned way.   For the second file, it
>> preallocated a single inumber.   For the third file, it preallocates
>> 2 inumbers.   On the fifth file creation, it preallocates 4
>> inumbers.  And so forth.
>>
>> One obstacle to getting FSS to use any of these ideas is that we
>> currently support only NFSv3.   We need to get an NFSv4 server
>> going, and then we'll be interested in doing the server work to
>> speed up these kinds of metadata workloads.
>>
>> -Bradley
>>
>> On 4/4/19 11:22 AM, Chuck Lever wrote:
>>>> On Apr 4, 2019, at 11:09 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>>>>
>>>> On Wed, Apr 3, 2019 at 9:06 PM bfields@fieldses.org
>>>> <bfields@fieldses.org> wrote:
>>>>> On Wed, Apr 03, 2019 at 12:56:24PM -0400, Bradley C. Kuszmaul wrote:
>>>>>> This proposal does look like it would be helpful.   How does this
>>>>>> kind of proposal play out in terms of actually seeing the light of
>>>>>> day in deployed systems?
>>>>> We need some people to commit to implementing it.
>>>>>
>>>>> We have 2-3 testing events a year, so ideally we'd agree to show up with
>>>>> implementations at one of those to test and hash out any issues.
>>>>>
>>>>> We revise the draft based on any experience or feedback we get.  If
>>>>> nothing else, it looks like it needs some updates for v4.2.
>>>>>
>>>>> The on-the-wire protocol change seems small, and my feeling is that if
>>>>> there's running code then documenting the protocol and getting it
>>>>> through the IETF process shouldn't be a big deal.
>>>>>
>>>>> --b.
>>>>>
>>>>>> On 4/2/19 10:07 PM, bfields@fieldses.org wrote:
>>>>>>> On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
>>>>>>>> The create itself needs to be sync, but the attribute delegations mean
>>>>>>>> that the client, not the server, is authoritative for the timestamps.
>>>>>>>> So the client now owns the atime and mtime, and just sets them as part
>>>>>>>> of the (asynchronous) delegreturn some time after you are done writing.
>>>>>>>>
>>>>>>>> Were you perhaps thinking about this earlier proposal?
>>>>>>>> https://urldefense.proofpoint.com/v2/url?u=https-3A__tools.ietf.org_html_draft-2Dmyklebust-2Dnfsv4-2Dunstable-2Dfile-2Dcreation-2D01&d=DwIBAg&c=RoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=YIKOmJLMLfe5wQR3VJI7jGjCnepZlMwumApzvaKItrY&m=qlAJ6dZPGjbcTzNIpkTyk-RTii6lWw1CLIjF6jp3P2Y&s=aTTFNJlRH-dXrQmE4cSYEUd8Kv3ij5cqTJtvgIixMa8&e=
>>>>>>> That's it, thanks!
>>>>>>>
>>>>>>> Bradley is concerned about performance of something like untar on a
>>>>>>> backend filesystem with particularly high-latency metadata operations,
>>>>>>> so something like your unstable file createion proposal (or actual write
>>>>>>> delegations) seems like it should help.
>>>>>>>
>>>>>>> --b.
>>>> The serialized create with something like an untar is a
>>>> performance-killer though.
>>>>
>>>> FWIW, I'm working on something similar right now for Ceph. If a ceph
>>>> client has adequate caps [1] for a directory and the dentry inode,
>>>> then we should (in principle) be able to buffer up directory morphing
>>>> operations and flush them out to the server asynchronously.
>>>>
>>>> I'm starting with unlink (mostly because it's simpler), and am mainly
>>>> just returning early when we do have the right caps -- after issuing
>>>> the call but before the reply comes in. We should be able to do the
>>>> same for link, rename and create too. Create will require the Ceph MDS
>>>> to delegate out a range of inode numbers (and that bit hasn't been
>>>> implemented yet).
>>>>
>>>> My thinking with all of this is that the buffering of directory
>>>> morphing operations is not as helpful as something like a pagecache
>>>> write is, as we aren't that interested in merging operations that
>>>> change the same dentry. However, being able to do them asynchronously
>>>> should work really well. That should allow us to better parallellize
>>>> create/link/unlink/rename on different dentries even when they are
>>>> issued serially by a single task.
>>> What happens if an asynchronous directory change fails (eg. ENOSPC)?
>>>
>>>
>>>> RFC5661 doesn't currently provide for writeable directory delegations,
>>>> AFAICT, but they could eventually be implemented in a similar way.
>>>>
>>>> [1]: cephfs capabilies (aka caps) are like a delegation for a subset
>>>> of inode metadata
>>>> --
>>>> Jeff Layton <jlayton@poochiereds.net>
>>> --
>>> Chuck Lever
>>>
>>>
>>>
