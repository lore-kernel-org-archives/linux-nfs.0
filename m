From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Thu, 11 Dec 2008 17:44:59 -0500
Message-ID: <20081211224459.GC24584@fieldses.org>
References: <49183A12.7010707@RedHat.com> <20081204211057.GC9593@fieldses.org> <18744.41310.635618.148281@notabene.brown> <20081205035803.GC15115@fieldses.org> <49392C14.7000709@RedHat.com> <20081205163824.GA29227@fieldses.org> <20081205172913.GB29227@fieldses.org> <6763B58B-6C3B-40FA-84F4-737E93D429A6@oracle.com> <20081206024241.GB5464@fieldses.org> <CADDDF36-C41E-4171-905B-CD48CB7BCFED@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37624 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757054AbYLKWpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Dec 2008 17:45:12 -0500
In-Reply-To: <CADDDF36-C41E-4171-905B-CD48CB7BCFED@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 08, 2008 at 02:50:39PM -0500, Chuck Lever wrote:
> Hi Bruce-
>
> On Dec 5, 2008, at Dec 5, 2008, 9:42 PM, J. Bruce Fields wrote:
>> On Fri, Dec 05, 2008 at 01:41:32PM -0500, Chuck Lever wrote:
>>> On Dec 5, 2008, at 12:29 PM, J. Bruce Fields wrote:
>>>> How about adding an explicit fsync() of the state file (and parent
>>>> directory) to statd's first succesful creation of a statd record,
>>>> together with a comment explaining this?  So around about line 194  
>>>> in
>>>> utils/statd/monitor.c:sm_mon_1_svc()?
>>>>
>>>> In fact, we could delete the sync entirely and do the same before  
>>>> the
>>>> first notification, and then we wouldn't have to wait for the sync  
>>>> in
>>>> the case host records are present either....  (statd would, but
>>>> perhaps we could still get other work done in the mean time).
>>>>
>>>> (Am I missing something?)
>>>
>>> This all might work, but I think we're adding a lot of complexity as 
>>> a
>>> workaround.
>>
>> I think you mean the justification is too subtle--the code itself  
>> (just
>> a couple syncs or fsyncs) is pretty simple.
>
> Let me state it another way.  Your suggested redesign makes assumptions 
> about the order in which these operations are performed.  Can the code 
> provide any guarantee that this ordering is always true?  This may have 
> been feasible when rpc.statd did notification too, but these are now two 
> separate programs.  Can you think of a way of implementing this where the 
> ordering dependencies are coded instead of commented?

The existing code requires that we update the on-disk nsm state number
before doing notification or accepting statd calls.  That's the only
ordering I'd require.

Maybe I should try to write a patch.

--b.

>
> It would be significantly less fragile (ie immune to ordering problems  
> and long-term changes to system start-up and nfs-utils code) and simpler 
> to understand if sm-notify does whatever syncing it needs, and rpc.statd 
> does whatever syncing it needs.
>
> All I'm saying is this scheme may be easy to break by accident, and any 
> future problem here is probably not going to show up until someone  
> really needs this to work right.
>
>>> Someone should fix the real problem, which is the
>>> implementation of sync().
>>
>> I think you mean of fsync().  My understanding of past discussions on
>> the issue is that it's not really fixable on ext3, at least.  So
>> default setups will have this problem for a while.
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
