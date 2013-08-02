Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19091 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556Ab3HBQ4c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 12:56:32 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: SP4_MACH_CRED
Date: Fri, 2 Aug 2013 16:56:31 +0000
Message-ID: <8C2E657F-5308-4A22-98D8-B2996F40F194@netapp.com>
References: <A0A1021A-64E6-4E0C-89A5-9F719C8E1AFC@netapp.com>
 <20130731213904.GB2668@fieldses.org>
 <75E5568D-320C-45A1-B7E6-23CE73217BAF@netapp.com>
 <20130731234800.GC2668@fieldses.org>
 <0E0FF4CB-4388-417B-9D1C-24940472D844@netapp.com>
 <47D6EDEC-B91A-446F-A227-FDA9D37DB618@netapp.com>
 <20130801145617.GA15123@fieldses.org>
 <88EAD768-768D-43A3-8E4D-D9B904C0283C@netapp.com>
 <20130801190526.GB17581@fieldses.org>
In-Reply-To: <20130801190526.GB17581@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 1, 2013, at 3:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Thu, Aug 01, 2013 at 03:24:05PM +0000, Adamson, Dros wrote:
>> 
>> On Aug 1, 2013, at 10:56 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>>> So the choices are:
>>> 	1. allow those problems, or
>>> 	2. change the nfs/krb5 security model from "once you give a
>>> 	   client your credential, you trust it with your data till the
>>> 	   credential expires" to "once you give a client your
>>> 	   credential, you trust it indefinitely".  (Well, until its
>>> 	   state expires, anyway.)
>>> 
>>> And we can implement either 1, or 2, or both, and if we implement both,
>>> we get to choose which of 1 or 2 is the default.
>>> 
>>> So I don't have a strong opinion yet, but I do fear that if we only
>>> implement #2 there will be users who see that as a serious regression in
>>> security.
>> 
>> Perhaps you're right - the server is essentially trusting the client machine to do the right thing here, but the server is already trusting the client machine (not users) to do the right thing.  A rouge client implementation could create all types of havoc as it stands now, i.e. using another user's credentials to bypass permissions, etc.
> 
> Right, but normally that capacity for havoc is time-limited.  For
> example, you're not affected if a client is compromised after your creds
> expire.
> 
> I think that's pretty important.  So let's make this optional.  I'm
> willing to argue about the default policy.
> 
> Do all the operations that might conceivably be affected by this take
> filehandles?  If so an export option might make sense.  Something like
> 
> 	trust_client_writeback
> 
> 		NFSv4.1 and higher clients who have accessed a file
> 		using a user's credential will be permitted further
> 		write access to that file using only their machine
> 		credential.  Some clients can take advantage of this to
> 		write back cached data after user credentials expire,
> 		preventing possible data loss in some cases.
> 
> Maybe there's a better name!

Making an option is fine with me.  I think we'll eventually want it to be the default, but we'll still need a way to disable it.

-dros

> 
> --b.

