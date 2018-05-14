Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59726 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752259AbeENVHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 May 2018 17:07:40 -0400
Date: Mon, 14 May 2018 17:07:40 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: SETCLIENTID acceptor
Message-ID: <20180514210740.GC29264@fieldses.org>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
 <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
 <8E0A99E2-7037-4023-99F5-594430919604@oracle.com>
 <CAN-5tyFQ9vbTHQJ7g4_0sVLCO2ppyTmTcrww5t_SD-x9yg6u5A@mail.gmail.com>
 <7964A589-32F6-4881-9706-775A82C20103@oracle.com>
 <CAN-5tyEM4NATLAQky2evmyaM06d+vrZf0A5Sw6MggJsWmsVeFw@mail.gmail.com>
 <2C808B88-619E-4F7C-9817-4937C4A2427B@oracle.com>
 <CAN-5tyH-WErrT33VYsXVgjkpq35qCen9ZPjc1M73Cec4ipNfsQ@mail.gmail.com>
 <D9D58278-855E-414E-A340-E47B5BEA7FD9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D9D58278-855E-414E-A340-E47B5BEA7FD9@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2018 at 02:02:19PM -0400, Chuck Lever wrote:
> I erased the gssproxy cache, and that appears to have fixed
> the client misbehavior. I'm still using gssproxy, and I was
> able to use NFSv4.0 with Kerberos on my TCP-only i/f, then
> on my IB i/f, then on my RoCE i/f without notable problems.
> 
> Since gssproxy is the default configuration on RHEL 7-based
> systems, I think we want to make gssproxy work rather than
> disabling it -- unless there is some serious structural 
> problem that will prevent it from ever working right.

Yeah.  Maybe discuss it with Simo or someone if we've figured out what's
actually going on.

--g.
