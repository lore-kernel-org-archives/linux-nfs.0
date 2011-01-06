Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761Ab1AFNMO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 08:12:14 -0500
Message-ID: <4D25BFA2.9060002@RedHat.com>
Date: Thu, 06 Jan 2011 08:12:02 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Timo Aaltonen <timo.aaltonen@aalto.fi>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Support AD style kerberos automatically in rpc.gss
References: <20101222192227.GA31112@obsidianresearch.com> <alpine.DEB.2.00.1012231240220.20516@kosh.org.aalto.fi> <20110104213207.GA1211@obsidianresearch.com>
In-Reply-To: <20110104213207.GA1211@obsidianresearch.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 01/04/2011 04:32 PM, Jason Gunthorpe wrote:
> On Thu, Dec 23, 2010 at 12:55:16PM +0200, Timo Aaltonen wrote:
>> On Wed, 22 Dec 2010, Jason Gunthorpe wrote:
>>
>>> An Active Directory KDC will only grant a TGT for UPNs, getting
>>> a TGT for SPNs is not possible:
>>>
>>> $ kinit -k host/ib5@ADS.ORCORP.CA
>>> kinit: Client not found in Kerberos database while getting initial credentials
>>>
>>> The correct thing to do for machine credentials is to get a TGT
>>> for the computer UPN <HOSTNAME>$@REALM:
>>> $ kinit -k IB5\$
>>> $ klist
>>> 12/22/10 11:43:47  12/22/10 21:43:47  krbtgt/ADS.ORCORP.CA@ADS.ORCORP.CA
>>>
>>> Samba automatically creates /etc/krb5.keytab entry for the computer UPN,
>>> this patch makes gssd_refresh_krb5_machine_credential prefer it above
>>> the SPNs if it is present.
>>>
>>> The net result is that nfs client works automatically out of the box
>>> if samba has been used to setup kerberos via 'net ads join' 'net ads
>>> keytab create'
>>>
>>> Tested using Windows Server 2003 R2 as the AD server.
>>
>> This is basically what I did earlier, see:
>>
>> http://marc.info/?l=linux-nfs&m=128108638228797&w=2
>>
>> though I still haven't cleaned it up as promised..
> 
> Right, mine is a bit more complete (man page updated, etc) but it does
> the same thing.
> 
> Maybe we can get a nfs-utils maintainer to comment this time?
Sorry for the delay.... I'll trying to get to this asap... 

steved.
