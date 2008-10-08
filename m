From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Bug#484861: nfs-common: rpc.statd --outgoing-port (-o) option
 broken
Date: Wed, 08 Oct 2008 08:47:50 -0400
Message-ID: <48ECABF6.40107@RedHat.com>
References: <20080607015302.15770.62792.reportbug@gothic-ave.svl.ibm.com> <20081005045133.GZ26991@debianrules.debiancolombia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org, Richard A Nelson <cowboy@debian.org>,
	484861@bugs.debian.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57317 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754985AbYJHMt0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 08:49:26 -0400
In-Reply-To: <20081005045133.GZ26991-ePWG1nzy00eujY+JMLXK6WCv5UukjcD9wsqeKsqY1Ps@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



An=EDbal Monsalve Salazar wrote:
> On Sat, Jun 07, 2008 at 01:53:02AM +0000, Richard A Nelson wrote:
>> Package: nfs-common
>> Version: 1:1.1.2-4
>> Severity: important
>>
>> In a fit of debugging spurious NFS problems I noticed this:
>>
>> # ps auxw | grep statd
>> statd     4136  0.0  0.0   2056   652 ?        Ss   Jun06   0:00
>> /sbin/rpc.statd --port 32765 --outgoing-port 32766
>>
>> # lsof | grep rpc.statd | grep :
>> rpc.statd  4136       statd    5u     IPv4      10388 UDP *:920=20
>> rpc.statd  4136       statd    7u     IPv4      10396 UDP *:32765=20
>> rpc.statd  4136       statd    8u     IPv4      10399 TCP *:32765 (L=
ISTEN)
>>
>> changing --outgoing-port to -o didn't help.
>>
>> This is causing issues with my firewalls
>=20
> Is this a known bug in 1.1.2?
No...=20

Please file a bug report at https://bugzilla.linux-nfs.org

steved.

