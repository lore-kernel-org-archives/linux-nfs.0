Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:44902 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453Ab0LHUel convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 15:34:41 -0500
Subject: Re: mount.nfs timeout of 9999ms (was Re: Listen backlog set to 64)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101208183738.GA9996@fieldses.org>
Date: Wed, 8 Dec 2010 15:34:20 -0500
Cc: Mark Hills <mark@pogo.org.uk>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Message-Id: <F1709324-D45E-4BEF-B3C7-D7341E026730@oracle.com>
References: <20101117090826.4b2724da@notabene.brown> <20101129205935.GD9897@fieldses.org> <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz> <20101130200013.GA2108@fieldses.org> <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz> <F5FCB254-E6CE-4B71-ABD9-33F098F9E0BA@oracle.com> <alpine.NEB.2.01.1012071143080.28772@jrf.vwaro.pbz> <C751B327-E608-4659-A96C-0B99C2C168E1@oracle.com> <alpine.NEB.2.01.1012081701170.11201@jrf.vwaro.pbz> <45243C0D-2158-47DD-91AF-C91AB960F6B4@oracle.com> <20101208183738.GA9996@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 8, 2010, at 1:37 PM, J. Bruce Fields wrote:

> On Wed, Dec 08, 2010 at 01:28:06PM -0500, Chuck Lever wrote:
>> From what I have read, the server's configuration is the immediate problem here: namely that the disk that /var is on is slow, or there are bugs (or not-very-useful behavior) in the file system implementation used on /var, or that rpm should not cause such latency for other applications, or that the multi-threading architecture of mountd is incorrect.  Or some combination of these.
>> 
>> A ten second latency for file system operations is the real issue.
>> 
>>>> IMO adding another mount option would be mistaken.  It adds clutter to 
>>>> the mount user interface to work around what is clearly a problem on the 
>>>> server.
>>> 
>>> I agree that new options can be cluttered.
>>> 
>>> But I think the problem needs attention at both the client and sever side.
>> 
>> It seems reasonable to relax mount.nfs's timeout settings used when performing mount and rpcbind requests.  The question I have is what would be reasonable values to use instead of what we have?  (That question is directed to everyone who is still reading).
> 
> What's the behavior you want when the server is just off or unreachable?
> 
> I'd've thought that there are cases where you just want the mount to
> hang till it's interrupted or the problem is fixed.  (Autofs possibly
> being one of them.)

Perhaps we should retry in this case until the mount succeeds or the retry= timeout expires.  Then the value of NFSRPC_TIMEOUT_TCP would be inconsequential.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




