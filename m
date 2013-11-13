Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:31592 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758105Ab3KMRFN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 12:05:13 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH v2 3/3] nfs: check if gssd is running before attempting to use krb5i auth in SETCLIENTID call
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131113112050.381708de@corrin.poochiereds.net>
Date: Wed, 13 Nov 2013 12:05:06 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Message-Id: <081CCF9F-A3BC-46AB-831F-22B002734C7F@oracle.com>
References: <1384353053-30002-1-git-send-email-jlayton@redhat.com> <1384353053-30002-4-git-send-email-jlayton@redhat.com> <DF1DECB2-B736-4B70-87DC-52CD695C44F3@oracle.com> <1CFBCCB6-37CE-4C49-91EE-0FB33D11B57A@netapp.com> <4226B463-0DB1-4847-9C30-252E67B46859@oracle.com> <20131113103510.6f89a998@corrin.poochiereds.net> <A8619700-BAA2-4E99-AFFA-579115D4B68A@netapp.com> <20131113105702.6196aef0@corrin.poochiereds.net> <20131113110905.1e0cc276@corrin.poochiereds.net> <65F8741A-B846-472B-A569-A1C6FB39DEC7@oracle.com> <20131113112050.381708de@corrin.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 11:20 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 13 Nov 2013 11:10:52 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Nov 13, 2013, at 11:09 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>> 
>>> So to clarify...today we do this when gssd isn't running and we try an
>>> AUTH_GSS mount:
>>> 
>>> - attempt SETCLIENTID with krb5i
>>> - when that fails, log a warning to ring buffer
>>> - attempt SETCLIENTID with AUTH_SYS
>>> - attempt rest of mount with krb5i
>> 
>> Hold it.  This step should not be happening.  Lease management should try krb5i by default, but why is the rest of the mount attempted with krb5i?
>> 
> 
> Sorry, I should have been more clear...the rest of the mount is
> attempted with krb5i because sec=krb5i was specified on the command
> line.
> 
> IOW, this patch just shortcuts  attempting to do the lease
> establishment with krb5i when we know that that will fail. The main
> benefit being that we don't end up logging a warning about AUTH_GSS not
> running in that case.
> 
> The warning will be logged if/when a later call attempts to use GSSAPI.

Just a thought: The usual way we have of dealing with problems like this is WARN_ONCE() (or a user space equivalent).


-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




