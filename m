Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:58913 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932897AbZHDR5n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 13:57:43 -0400
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Message-Id: <0CDB8687-4C65-41D8-AB02-D5073EE568E2@oracle.com>
From: Chuck Lever <Chuck.Lever@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1249408157.5041.6.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: NFS/IPv6
Date: Tue, 4 Aug 2009 13:57:31 -0400
References: <1249407324.5041.4.camel@heimdal.trondhjem.org> <57B0749C-FFCC-4D8C-9417-DF18C0A3CD48@oracle.com> <1249408157.5041.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 4, 2009, at 1:49 PM, Trond Myklebust wrote:

> On Tue, 2009-08-04 at 13:37 -0400, Chuck Lever wrote:
>> On Aug 4, 2009, at 1:35 PM, Trond Myklebust wrote:
>>> Hi guys,
>>>
>>> There was apparently a presentation and proposal made at the IETF in
>>> Stockholm w.r.t. standardising IPv6 support in lockd/statd, and  
>>> adding
>>> link-local addresses to NFSv4. The proposal could possibly have
>>> consequences for our implementation efforts.
>>>
>>> Please see the slides and minutes here
>>>
>>> http://www.ietf.org/proceedings/75/minutes/nfsv4.txt
>>>
>>> and
>>>
>>> http://www.ietf.org/proceedings/75/slides/nfsv4-0.pdf
>>
>> Was Mike Eisler involved?  I recently reviewed a draft RFC on this
>> topic.
>
> Mike didn't present it, but the person who did was indeed from NetApp,
> so it is possible that this is the same RFC...

I've reviewed Alex's RFC.  It attempts to nail down a lot of  
ambiguities in the rpcbind protocol as well as provide some best  
practices for implementors.

The big issue for us is multi-homed support for lockd.  IPv6 support  
means mixed family clients and servers have at least two IP addresses;  
it automatically means our systems are now multi-homed.  Our lockd/ 
statd doesn't really work well in multi-homed environments, so that's  
an area I've been reviewing.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
