Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] svcauth_gss: Revert 64c59a3726f2 ("Remove unnecessary allocation")
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160906210149.GB30260@fieldses.org>
Date: Tue, 6 Sep 2016 17:25:38 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, bcodding@redhat.com
Message-Id: <B18D986B-5CC2-4D73-AD9C-525DBB4B93AD@oracle.com>
References: <20160901144839.6035.63068.stgit@klimt.1015granger.net> <20160906204238.GA30260@fieldses.org> <F9C6309A-2444-4B40-82D0-4BE90F19490A@oracle.com> <20160906210149.GB30260@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2016, at 5:01 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Sep 06, 2016 at 04:49:33PM -0400, Chuck Lever wrote:
>> 
>> On Sep 6, 2016, at 4:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> Apologies, I wasn't thinking when I wrote that patch.  The problem is
>>> probably that rsc_lookup steals the passed-in memory to avoid doing an
>>> allocation of its own, so we can't just pass in a pointer to memory that
>>> someone else is using....
>>> 
>>> If we really want to avoid allocation there then maybe we should
>>> preallocate somwhere, or reference count these handles.
>>> 
>>> For now reverting sounds like the right thing to do.
>> 
>> NP, thanks for confirming!
>> 
>> 
>>> Ben, did you ever confirm whether this helped with the problem you were
>>> seeing?  (If I remember correctly, unnpredictable delays here could
>>> cause the request to be dropped if later requests push the rpcsec_gss
>>> sequence window too far.)  If so then we could look into reference
>>> counting.
>> 
>> Well that's interesting.
>> 
>> When a request is dropped, would the server disconnect? Because if it
>> doesn't, the client will wait forever.
> 
> Checking... gss_verify_header returns SVC_DROP, which is just a silent
> close (SVC_CLOSE would close the connection).
> 
> I'm not sure what's correct there.

Right, we may not get any guidance from the RPCSEC GSS specifications.

However, the Linux NFS client retransmit code was changed in 2013 so that
NFSv4 never retransmits until the server drops the connection, starting
around commit 8a19a0b6cb2e2216afd68ef2047f30260cc8a220.

SVC_CLOSE might be a better choice, at least for NFSv4.


--
Chuck Lever
