Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:32799 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073Ab2DUM3s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Apr 2012 08:29:48 -0400
Message-ID: <4F929B50.1020407@steve-ss.com>
Date: Sat, 21 Apr 2012 13:34:40 +0200
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: simo <idra@samba.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Jeremy Allison <jra@samba.org>,
        linux-nfs@vger.kernel.org,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        Ondrej Valousek <webserv@s3group.com>
Subject: Re: NFSv4 ACLs
References: <4F913492.8000402@s3group.cz> <20120420185553.GB32622@samba2>  <20120420212627.GA710@fieldses.org> <20120420215945.GE32622@samba2>  <20120420220832.GA1914@fieldses.org> <1334972084.2492.722.camel@pico.li.ssimo.org>
In-Reply-To: <1334972084.2492.722.camel@pico.li.ssimo.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 21/04/12 03:34, simo wrote:
> On Fri, 2012-04-20 at 18:08 -0400, J. Bruce Fields wrote:
>> On Fri, Apr 20, 2012 at 02:59:45PM -0700, Jeremy Allison wrote:
>>> On Fri, Apr 20, 2012 at 05:26:27PM -0400, J. Bruce Fields wrote:
>>>> On Fri, Apr 20, 2012 at 11:55:53AM -0700, Jeremy Allison wrote:
>>>>> On Fri, Apr 20, 2012 at 12:04:02PM +0200, Ondrej Valousek wrote:
>>>>>> Hi List,
>>>>>>

>
>> (By the way, is reexporting nfs with samba really going to work well
>> anyway?)
>
> Not really, it is generally unsupported, except for read only shares. It
> will work in most of the simple cases for writing .. until it breaks :)
>

Hi
That's worrying.

We been rw'ing nfs/samba for years.  Maybe we're the only ones. nfs3 for 
our Linux clients and samba for the rest. Same shared data. Only Posix 
acl's though. Maybe that's the simple bit?
Cheers,
Steve
