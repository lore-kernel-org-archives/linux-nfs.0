Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp103.biz.mail.gq1.yahoo.com ([98.137.12.178]:31687 "HELO
	smtp103.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753813Ab2K3Ad4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 19:33:56 -0500
Message-ID: <50B7FEFB.30109@schaufler-ca.com>
Date: Thu, 29 Nov 2012 16:34:03 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <50ABF1A5.2010406@schaufler-ca.com> <50AC1A74.7080105@davequigley.com> <50AC2117.801@schaufler-ca.com> <50AC224D.3080108@davequigley.com> <50AC41DC.5070607@schaufler-ca.com> <50AC4A7A.6010208@davequigley.com> <50B65E7E.4030607@schaufler-ca.com> <50B6B706.1010002@davequigley.com> <50B6C398.90002@schaufler-ca.com> <50B7E189.80200@schaufler-ca.com> <d0817140372d745df0b4952b796610f2@countercultured.net>
In-Reply-To: <d0817140372d745df0b4952b796610f2@countercultured.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2012 4:07 PM, David Quigley wrote:
> On 11/29/2012 17:28, Casey Schaufler wrote:
>> On 11/28/2012 6:08 PM, Casey Schaufler wrote:
>>> On 11/28/2012 5:14 PM, Dave Quigley wrote:
>>>> On 11/28/2012 1:57 PM, Casey Schaufler wrote:
>>>>> On 11/20/2012 7:28 PM, Dave Quigley wrote:
>>>>>> On 11/20/2012 9:52 PM, Casey Schaufler wrote:
>>>>>>> On 11/20/2012 4:37 PM, Dave Quigley wrote:
>>>>>>>> ...
>>>>>>>>
>>>>>>>>
>>>>>>>> Or I could just give you this link and you should be good to go ;)
>>>>>>>>
>>>>>>>> http://www.selinuxproject.org/~dpquigl/nfs-utils-rpms/
>>>>>>>>
>>>>>>>> I haven't tried it but it should work. If it doesn't let me
>>>>>>>> know and
>>>>>>>> i'll try to fix it on my end. I'd imagine you might need to yum
>>>>>>>> remove
>>>>>>>> nfs-utils first before adding this new one or you could also
>>>>>>>> try an
>>>>>>>> rpm with the upgrade flag for this instead. Good luck.
>>>>> ...
>>>>>
>>>>>
>>>>> I've tried on Fedora17 and Ubuntu12.04, and I'm getting the
>>>>> attached stack trace on mount. After mounting I'm getting
>>>>> denials when I should, but also when I shouldn't.
>>>>>
>>>>> I've tried tracking down the issue, but there's a lot going on
>>>>> that I don't find obvious. I added a dentry_init hook just for
>>>>> grins, but it's not getting called.
>>>>>
>>>>> .
>>>>>
>>>>>
>>>> Any chance of you throwing a kickstart file my way that's configured
>>>> with SMACK so I can use it for a test box (both server and client)? I
>>>> can have the guys working with me test for SMACK as well if you
>>>> provide an appropriate test harness and image for testing.
>>> I've attached the .config from my Fedora17 machine. Who knows, maybe
>>> I got something wrong there. I get the error doing the test on the
>>> loopback interface (mount -t nfs4 localhist:/ /mnt).
>>
>> I've done some instrumentation and security_ismaclabel() is getting
>> called with "selinux", but never "SMACK64". I would guess that somewhere
>> in the tools you're telling the kernel to expect "selinux". Where is
>> that, so that I can tell it to try "SMACK64" instead?
>>
>>
>>
>> -- 
>> This message was distributed to subscribers of the selinux mailing list.
>> If you no longer wish to subscribe, send mail to
>> majordomo@tycho.nsa.gov with
>> the words "unsubscribe selinux" without quotes as the message.
>
>
> What tools do you use in SMACK to see the labels?

attr -S -g SMACK64 <path>

> Do you just use getxattr? If so can you try calling that and seeing
> what happens? I'm concerned that you aren't getting any attribute
> information on that file.

I would think that were it not for the case that access is denied
and I get an audit record for nfsd that reports a subject label of "_"
(which is correct for nfsd but not the process attempting access) and
an object label of "WhooHoo", which is correct. The server side
looks like it might be working right, given the information that it
has.

> Do you have a disto that I can use that has full smack integration and
> is easy to setup?

There's no full integration, but Ubuntu is easy to set up because they
compile in all the LSMs.
Set "security=smack" on the boot line in grub.cfg and reboot.

All processes and files will get the floor ("_") label unless you change
one. You can change
a file label with:
     # attr -S -s SMACK64 WhooHoo path
or execute at a different label with:
    # (echo WhooHoo > /proc/self/attr/current ; command)


>
> Dave
> -- 
> To unsubscribe from this list: send the line "unsubscribe
> linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

