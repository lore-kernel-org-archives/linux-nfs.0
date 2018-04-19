Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56134 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752294AbeDSPww (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 11:52:52 -0400
Date: Thu, 19 Apr 2018 11:52:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Subject: Re: nfsd issue with a kerberized callback
Message-ID: <20180419155250.GA578@parsley.fieldses.org>
References: <680B7A1A-792A-4B9E-A0CA-46E459B65077@netapp.com>
 <20180416212942.GA2634@parsley.fieldses.org>
 <EC52DFFD-CB6F-45F5-BAB9-C684C205DE26@netapp.com>
 <20180417132156.GA10291@parsley.fieldses.org>
 <CAN-5tyEW+vZ1gYeP8zey1SkvuzXsJwdmrG=ZEXi6XXEVNM9Z_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAN-5tyEW+vZ1gYeP8zey1SkvuzXsJwdmrG=ZEXi6XXEVNM9Z_w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 19, 2018 at 11:10:06AM -0400, Olga Kornievskaia wrote:
> On Tue, Apr 17, 2018 at 9:21 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Mon, Apr 16, 2018 at 08:05:44PM -0400, Olga Kornievskaia wrote:
> >> > On Apr 16, 2018, at 5:29 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> >> I believe what’s happening is that because the client hasn’t received
> >> >> CB_NULL that establishes a callback channel but got a CB_RECALL it’s
> >> >> just ignoring it.
> >> >
> >> > I see two succesful CB_NULL calls and replies, so I think the context
> >> > establishment worked.  I don't know why there's a third CB_NULL in frame
> >> > 285.
> >>
> >> The two CB_NULL calls are both gss_init calls. They are not RPC NULL call. Server for some reason establishes 2 different gss context (again not necessarily a problem). The 3rd CB_NULL is gss_data and it sends an actual NULL call. I believe that’s the one that establishes a callback channel.
> >
> > Oh, I see.  No, that NULL call isn't necessary.  It's just the server
> > probing to see whether the callback channel works.  That NULL call isn't
> > required by the spec and everything should still work if the CB_RECALL
> > is sent out before it completes.
> 
> Ok thank you. Another question: can the nfsd decide to give out
> delegation regardless of the existence of the callback path? Looking
> at the nfsd open code I see that it checks if cl_cb_state is
> NFSD4_CB_UP. But I guess somehow (according to this trace), it finds
> it up? Any ideas, looks like a bug...

That CB_NULL isn't required by the spec and the lack of it shouldn't
bother the client.  But, yes, you're right, I think it's still a bug if
the server's giving out a delegation before it returns, in the NFSv4.0
case.  There are so many ways the NFSv4.0 callback connection can fail
(firewalls, NAT, gss configuration...) that I'd rather not assume it's
up.

So, I agree, it's a bug, it just doesn't necessarily explain what's
going wrong here.

> On this particular network trace, in frame 240, the server gives out
> the read delegation (which is later on it's trying to recall). However
> the setup of the callback path(s) doesn't happen until frames 259/261
> (tcp connections are established starting from frames 253/256).
> 
> Goal is to try and reproduce this problem where the client is failing
> the CB_RECALL... but so far I can't trigger this.
> 
> Also I figured out why there are 2 SETCLIENTIDs and it's not because
> of the 2 mounts (with unmount in the middle). First SETCLIENTID is
> trunking discovery. Second SETCLIENTID is for when client is trying to
> do an operation requiring a clientid. Therefore this leads to
> existence of 2 callback paths (ie 2 CB_NULL gss context
> establishment). I'm not sure if this is somehow incorrect that client
> provides 2 callback path and server establishes context for both.

When I looked I think I saw that the second SETCLIENTID/CONFIRM uses the
same callback info as the first.  So the server shouldn't need to do
anything.  But it may actually close the connection and open a new one,
which is unnecessary but not necessarily wrong.  But if it's keeping two
connections around and trying to use both then something's definitely
misbehaving.

--b.
