Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:45878 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbbAON2i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Jan 2015 08:28:38 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1YBkTV-00049l-0j
	for linux-nfs@vger.kernel.org; Thu, 15 Jan 2015 14:28:37 +0100
Received: from server.vandervlis.nl ([82.95.148.152])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 15 Jan 2015 14:28:36 +0100
Received: from paul by server.vandervlis.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 15 Jan 2015 14:28:36 +0100
To: linux-nfs@vger.kernel.org
From: Paul van der Vlis <paul@vandervlis.nl>
Subject: Re: Max. open files?
Date: Thu, 15 Jan 2015 14:28:28 +0100
Message-ID: <54B7C07C.1080403@vandervlis.nl>
References: <m98a90$bh8$1@ger.gmane.org> <alpine.OSX.2.19.9992.1501150805380.27935@planck.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <alpine.OSX.2.19.9992.1501150805380.27935@planck.local>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben and others,

The problem what I see, is that I sometimes cannot do a "ls" in a
directory. It just gives no output and the terminal does not respond
anymore. No errors in the logs.

I've seen it in the firefox profile, like this:
/home/paul/.mozilla/firefox/0k48lsbe.default/
The browser hangs then.

No problems in other directories of the same user.

I am using homedirs on NFS4 with LDAP and MIT Kerberos on Debian Wheezy
with a 3.16 kernel. sec=krb5i.

With regards,
Paul .

Op 15-01-15 om 14:13 schreef Benjamin Coddington:
> Hi Paul van der Vlis,
> 
> I don't think there's a NFSD limit on open files, but you'd be subject to
> VFS' file-max.
> 
> http://lxr.free-electrons.com/source/Documentation/sysctl/fs.txt#L91
> 
> Ben
> 
> On Thu, 15 Jan 2015, Paul van der Vlis wrote:
> 
>> Hello,
>>
>> Is there in nfs-kernel-server a maximum on the open files?
>>
>> If yes, what's the correct way to change that maximum?
>>
>> Do I get errors in the logs when the maximum is reached?
>>
>> With regards,
>> Paul van der Vlis.
>>
>>
>> --
>> Paul van der Vlis Linux systeembeheer, Groningen
>> http://www.vandervlis.nl/
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 





-- 
Paul van der Vlis Linux systeembeheer, Groningen
http://www.vandervlis.nl/

