Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51843 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932553AbcEYQHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 12:07:52 -0400
Subject: Re: [RFC PATCH 0/1] Create a DNS SRV record of the ID mapping domain
To: Chuck Lever <chuck.lever@oracle.com>
References: <1464020307-8806-1-git-send-email-steved@redhat.com>
 <B7AD5C8F-13A3-466A-BAC8-8A487939BC8F@oracle.com>
 <8d2c592d-2c43-85e4-a9fb-65b13206c2ee@RedHat.com>
 <D7102E5D-3328-4379-B8F2-BFDA86AAEBE4@oracle.com>
 <c33c89df-ec54-fa6e-a84c-671f8a79f3c3@RedHat.com>
 <AB5249F6-36B2-44DF-864E-9F90D16A07FE@oracle.com>
 <995c5e10-61a0-d32c-dcab-1f6a4e943eae@RedHat.com>
 <96802553-B978-4044-8697-0CE0A85BC255@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <335b4fac-3b9e-4281-d620-9dd085c93c4d@RedHat.com>
Date: Wed, 25 May 2016 12:07:46 -0400
MIME-Version: 1.0
In-Reply-To: <96802553-B978-4044-8697-0CE0A85BC255@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/25/2016 11:25 AM, Chuck Lever wrote:
> 
>> On May 25, 2016, at 8:14 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> Does that even work? How can you have multiple domains
>> on the same host?
> 
> Which interface is used for the TXT record query?
I'm assuming the interfaces in /etc/resolv.conf

> If a system is on multiple networks with their
> own DNS services, it is possible for them to see
> a different TXT lookup result depending on which
> interfaces happen to be up when the query is done,
> and what DNS service has been set up by DHCP.
