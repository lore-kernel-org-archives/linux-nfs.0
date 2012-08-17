Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailservice.tudelft.nl ([130.161.131.5]:47085 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758773Ab2HQSfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2012 14:35:21 -0400
Message-ID: <502E8EBD.6040702@tudelft.nl>
Date: Fri, 17 Aug 2012 20:34:37 +0200
From: Richard <rsmits-l@tudelft.nl>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsv4 state id errors
References: <502E69FC.7080608@tudelft.nl> <4FA345DA4F4AE44899BD2B03EEEC2FA93B7B79@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93B7B79@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The person who reported this uses :

nfs-client-1.2.3-18.17.2
krb5-1.6.3-133.48.48.1

I will check next monday with him if this is still the version he uses.
He uses Suse Linux Enterprise Desktop 11.2.

We use nfs4/krb5 with Windows AD as KDC on a Fas3170.

Greetings.

On 17-8-2012 20:18, Myklebust, Trond wrote:
> On Fri, 2012-08-17 at 17:57 +0200, Richard wrote:
>> Hello,
>>
>> A couple of weeks agoo we upgraded our Netapp filer to 8.1.1RC1. We have
>> always had trouble with NFS and state id's. Resulting in hanging clients.
>>
>> Some bugs were fixed in 8.1.1 but still trouble.
>>
>> Now we have the following errors in our client messages file, after a hang.
>>
>> What does this : NFS: "v4 server srv returned a bad sequence-id error!"
>> means ?
> 
> Can you remind us which NFSv4 clients you are using?
> 
> At one point the NFSv4 client was reusing open owners after they fell
> out of the client cache, and that would create symptoms such as the
> above. That bug has since been fixed in the upstream kernel.
> 

