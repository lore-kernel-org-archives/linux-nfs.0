Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:23009 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911Ab1KGQ3i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 11:29:38 -0500
Subject: Re: rpcbind -h
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4EB80606.90309@RedHat.com>
Date: Mon, 7 Nov 2011 11:29:26 -0500
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Message-Id: <94E1D8B7-99A6-457C-BC8D-D8E27D41421D@oracle.com>
References: <20111106155844.GA1790@umich.edu> <4EB80606.90309@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 7, 2011, at 11:23 AM, Steve Dickson wrote:

> 
> 
> On 11/06/2011 10:58 AM, Jim Rees wrote:
>> Is there some good reason why the rpcbind '-h' option (bind to given
>> address) applies only to the udp listening socket and not to the tcp socket?
> No... sounds like a bug to me...

Behavior is described right in the man page.  So this seems to be on purpose.

     -h      Specify specific IP addresses to bind to for UDP requests.  This option
             may be specified multiple times and is typically necessary when running
             on a multi-homed host.  If no -h option is specified, rpcbind will bind
             to INADDR_ANY, which could lead to problems on a multi-homed host due to
             rpcbind returning a UDP packet from a different IP address than it was
             sent to.  Note that when specifying IP addresses with -h, rpcbind will
             automatically add 127.0.0.1 and if IPv6 is enabled, ::1 to the list.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




