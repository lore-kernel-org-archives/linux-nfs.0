Return-Path: paul@vandervlis.nl
Message-ID: <54B7C923.70005@vandervlis.nl>
Date: Thu, 15 Jan 2015 15:05:23 +0100
From: Paul van der Vlis <paul@vandervlis.nl>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Max. open files?
References: <m98a90$bh8$1@ger.gmane.org> <alpine.OSX.2.19.9992.1501150805380.27935@planck.local> <54B7C07C.1080403@vandervlis.nl> <alpine.OSX.2.19.9992.1501150851530.27935@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1501150851530.27935@planck.local>
Content-Type: text/plain; charset=utf-8
List-ID: <linux-nfs.vger.kernel.org>

Hello Ben and others,

Op 15-01-15 om 14:53 schreef Benjamin Coddington:
> Can you provide a network capture of the problem?

Not at the moment.

Do you think it's good to make a tcpdump as root on the client when the
problem is there?

tcpdump -nw /path/filename

With regards,
Paul van der Vlis


> Ben
> 
> On Thu, 15 Jan 2015, Paul van der Vlis wrote:
> 
>> Hi Ben and others,
>>
>> The problem what I see, is that I sometimes cannot do a "ls" in a
>> directory. It just gives no output and the terminal does not respond
>> anymore. No errors in the logs.
>>
>> I've seen it in the firefox profile, like this:
>> /home/paul/.mozilla/firefox/0k48lsbe.default/
>> The browser hangs then.
>>
>> No problems in other directories of the same user.
>>
>> I am using homedirs on NFS4 with LDAP and MIT Kerberos on Debian Wheezy
>> with a 3.16 kernel. sec=krb5i.
>>
>> With regards,
>> Paul .
>>
>> Op 15-01-15 om 14:13 schreef Benjamin Coddington:
>>> Hi Paul van der Vlis,
>>>
>>> I don't think there's a NFSD limit on open files, but you'd be subject to
>>> VFS' file-max.
>>>
>>> http://lxr.free-electrons.com/source/Documentation/sysctl/fs.txt#L91
>>>
>>> Ben
>>>
>>> On Thu, 15 Jan 2015, Paul van der Vlis wrote:
>>>
>>>> Hello,
>>>>
>>>> Is there in nfs-kernel-server a maximum on the open files?
>>>>
>>>> If yes, what's the correct way to change that maximum?
>>>>
>>>> Do I get errors in the logs when the maximum is reached?
>>>>
>>>> With regards,
>>>> Paul van der Vlis.
>>>>
>>>>
>>>> --
>>>> Paul van der Vlis Linux systeembeheer, Groningen
>>>> http://www.vandervlis.nl/
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>>
>>
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





-- 
Paul van der Vlis Linux systeembeheer, Groningen
http://www.vandervlis.nl
