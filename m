Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37328 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab1BBF4X convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Feb 2011 00:56:23 -0500
Subject: Re: [PATCH 1/3] pnfs: avoid incorrect use of layout stateid
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <4D48DB59.9010102@panasas.com>
References: <1296487633-21057-1-git-send-email-iisaman@netapp.com>
	 <1296487633-21057-2-git-send-email-iisaman@netapp.com>
	 <4D4828DC.9020103@panasas.com>
	 <AF70A3A4-2A06-4BD1-AC69-270658CF6365@netapp.com>
	 <4D48DB59.9010102@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Feb 2011 00:56:05 -0500
Message-ID: <1296626165.8895.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-02-02 at 06:19 +0200, Benny Halevy wrote: 
> On 2011-02-01 18:31, Fred Isaman wrote:
> > 
> > On Feb 1, 2011, at 10:38 AM, Benny Halevy wrote:
> > 
> >> On 2011-01-31 17:27, Fred Isaman wrote:
> >>> The code could violate the following from RFC5661, section 12.5.3:
> >>> "Once a client has no more layouts on a file, the layout stateid is no
> >>> longer valid and MUST NOT be used."
> >>
> >> NACK.
> >>
> >> Fred, this is your interpretation of the forgetful model and it is taken
> >> out of context.
> >>
> >> Until the spec is changed only the server invalidates the stateid by returning
> >> lrs_present=false on LAYOUTRETURN. Merely forgetting the layout state without
> >> LAYOUTRETURN does not determine that.
> >>
> >>
> >> Also from 12.5.3:
> >>   Once a layout stateid is established, the "other"
> >>   field will stay constant unless the stateid is revoked or the client
> >>   returns all layouts on the file and the server disposes of the stateid.
> >>   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> > OK, so the question is, does sending a LAYOUTGET with openstateid "return all layouts".
> > Making the answer to this "yes" is perfectly consistent with the spec, given its complete absence
> > of direction here.
> 
> I disagree, and so are other server implementations, including linux-pnfs!
> (It will return BAD_STATEID if the client forgets the layout
> in any case but LAYOUTRETURN or CB_LAYOUTRECALL/NOMATCHING_LAYOUT)

Where do you see this being allowed? I see nothing in RFC5661 that
justifies the server returning BAD_STATEID (or any other error) if the
client supplies an open stateid in LAYOUTGET. The only stateids that are
explicitly disallowed in section 12 are the special stateids.
IOW: I see no justification there for your interpretation or the above
error message. Fix the linux pnfs server and the "other server
implementation" if it does this.

The only text I can find is repeated in both section 12.5.2. and section
12.5.3 and states that the client uses an open stateid, delegation
stateid or lock stateid if it holds no layouts.
Section 12.5.5.1 then states that the client is allowed to forget
layouts and that this is safe as long as it doesn't assume it holds
layouts for ranges that lie beyond what the server granted. The same
section states that the server has no control over what the client
believes, and so it is allowed to recall a layout that the client knows
nothing about if it is in doubt.


Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

