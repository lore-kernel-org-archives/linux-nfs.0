Return-Path: <olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Sender: olga.kornievskaia@gmail.com
In-Reply-To: <alpine.OSX.2.19.9992.1505290942250.65323@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com>
	<alpine.OSX.2.19.9992.1505290942250.65323@planck.local>
Date: Fri, 29 May 2015 12:51:19 -0400
Message-ID: <CAN-5tyE2wepUkuBO=sWwkBpr+jfQzh1+c_QbNykLk=wy3A77UQ@mail.gmail.com>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID
From: Olga Kornievskaia <aglo@umich.edu>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 29, 2015 at 9:44 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> On Thu, 7 May 2015, Olga Kornievskaia wrote:
>
>> Hi folks,
>>
>> Problem:
>> The upstream nfs4.0 client has problem where it will go into an
>> infinite loop of re-sending an OPEN when it's trying to recover from
>> receiving a BAD_STATEID error on an IO operation such READ or WRITE.
>>
>> How to easily reproduce (by using fault injection):
>> 1. Do nfs4.0 mount to a server.
>> 2. Open a file such that the server gives you a write delegation.
>> 3. Do a write. Have a server return a BAD_STATEID. One way to do so is
>> by using a python proxy, nfs4proxy, and inject BAD_STATEID error on
>> WRITE.
>> 4. And off it goes with the loop.
>
> Hi Olga,
>
> I've been trying to reproduce it, and I'm frustratingly unable.  It sounds
> fairly easy to produce..  What version of the client produces this?
>

Hi Ben,

Problem exists in the upstream kernels as well but we noticed the
problem on RHEL7.1 distro (RedHat's 2.6.32-229.el7 kernel I think).

> Ben
