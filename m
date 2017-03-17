Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18032 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751023AbdCQOmP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 10:42:15 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: software error with bugzilla.linux-nfs.org
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1489761399.8441.3.camel@primarydata.com>
Date: Fri, 17 Mar 2017 10:41:38 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <37923C40-E6AC-474E-B8BA-32D5E3793B54@oracle.com>
References: <1BF99BE7-DE8A-436B-B5A7-9080D9E9AC93@gmail.com> <1489688316.11936.2.camel@primarydata.com> <0479196B-5B07-4836-B7F9-65064D98E32E@gmail.com> <7BB18FB2-FE2F-4788-B016-6039E9339F98@gmail.com> <1489761399.8441.3.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 17, 2017, at 10:36 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-03-17 at 10:25 -0400, Chuck Lever wrote:
>>> On Mar 16, 2017, at 2:23 PM, Chuck Lever <chucklever@gmail.com>
>>> wrote:
>>> 
>>>> 
>>>> On Mar 16, 2017, at 2:18 PM, Trond Myklebust <trondmy@primarydata
>>>> .com> wrote:
>>>> 
>>>> On Thu, 2017-03-16 at 13:59 -0400, Chuck Lever wrote:
>>>>> When I tried to add a comment to bug 291, this resulted:
>>>>> 
>>>>> DBD::mysql::db do failed: Incorrect key file for table
>>>>> './nfsv4_bugzilla/bugs_fulltext.MYI'; try to repair it [for
>>>>> Statement
>>>>> "UPDATE bugs_fulltext SET comments = ?, comments_noprivate = ?
>>>>> 鑱借伣鑱借伣鑱借伣鑱借伣鑱借伣鑱借伣鑱借伣鑱絎HERE bug_id = ?"] at Bugzilla/Bug.pm line 938.
>>>>> 	Bugzilla::Bug::_sync_fulltext(Bugzilla::Bug=HASH(0x3a1a
>>>>> 278))
>>>>> called at Bugzilla/Bug.pm line 886
>>>>> 	Bugzilla::Bug::update(Bugzilla::Bug=HASH(0x3a1a278),
>>>>> "2017-03-
>>>>> 16 10:58:16") called at /home/linux-
>>>>> nfs.org/nfsv4_bugzilla/process_bug.cgi line 547
>>>>> 
>>>>> Happened twice out of two attempts.
>>>> 
>>>> The backing mariadb database needed repair following a crash. I'm
>>>> hoping it is working now. Can you please retry?
>>> 
>>> Still not working. I guess this looks like the same error message.
>>> 
>>> DBD::mysql::db do failed: Incorrect key file for table
>>> './nfsv4_bugzilla/bugs_fulltext.MYI'; try to repair it [for
>>> Statement "UPDATE bugs_fulltext SET comments = ?,
>>> comments_noprivate = ?
>>> 聽聽聽聽聽聽聽聽聽聽聽聽聽聽WHERE bug_id = ?"] at Bugzilla/Bug.pm line 938.
>>> 	Bugzilla::Bug::_sync_fulltext(Bugzilla::Bug=HASH(0x421c4d8))
>>> called at Bugzilla/Bug.pm line 886
>>> 	Bugzilla::Bug::update(Bugzilla::Bug=HASH(0x421c4d8), "2017-03-
>>> 16 11:22:07") called at /home/linux-
>>> nfs.org/nfsv4_bugzilla/process_bug.cgi line 547
>> 
>> P'haps the easiest approach is to restore from a known-good backup,
>> and then replay recent changes.
>> 
> I did a rebuild of the database table entries after your second attempt
> failed yesterday. I've seen no further errors in the logs since then.

Confirmed, it appears to be working now. Thanks!


--
Chuck Lever



