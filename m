Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp106.biz.mail.ne1.yahoo.com ([98.138.207.13]:22973 "HELO
	smtp106.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932472Ab2K3QVe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 11:21:34 -0500
Message-ID: <50B8DD14.6080104@schaufler-ca.com>
Date: Fri, 30 Nov 2012 08:21:40 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: David Quigley <dpquigl@davequigley.com>
CC: Stephen Smalley <sds@tycho.nsa.gov>,
        "J. Bruce Fields" <bfields@fieldses.org>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Labeled NFS [v5]
References: <50AC4A7A.6010208@davequigley.com> <50B65E7E.4030607@schaufler-ca.com> <50B6B706.1010002@davequigley.com> <50B6C398.90002@schaufler-ca.com> <50B7E189.80200@schaufler-ca.com> <d0817140372d745df0b4952b796610f2@countercultured.net> <50B7FEFB.30109@schaufler-ca.com> <579e850139bd3d5a0c9155270d5d9fbe@countercultured.net> <50B810D2.2000401@schaufler-ca.com> <3ea3f70e0a5cdb99f1594019b7bd619d@countercultured.net> <20121130121437.GC614@fieldses.org> <607a8005d6c33a19c53b5ede29d81ef5@countercultured.net> <5170c3bd8900c36b372217af96e5e764@countercultured.net> <50B8B47F.5050206@tycho.nsa.gov> <c00cec058c2bd0cb7104a53ca680f6cb@countercultured.net> <50B8B9BF.7000802@tycho.nsa.gov> <7969331f8e30a7a1a60b1aa3c4a034d3@countercultured.net>
In-Reply-To: <7969331f8e30a7a1a60b1aa3c4a034d3@countercultured.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2012 6:02 AM, David Quigley wrote:

There are times when living by the correct ocean makes
life so much easier. Thanks all for the early morning
brain work.

> On 11/30/2012 08:50, Stephen Smalley wrote:
>> On 11/30/2012 08:35 AM, David Quigley wrote:
>>> On 11/30/2012 08:28, Stephen Smalley wrote:
>>>> On 11/30/2012 08:17 AM, David Quigley wrote:
>>>>> On 11/30/2012 07:57, David Quigley wrote:
>>>>>> On 11/30/2012 07:14, J. Bruce Fields wrote:
>>>>>>> On Thu, Nov 29, 2012 at 09:02:49PM -0500, David Quigley wrote:
>>>>>>>> On 11/29/2012 20:50, Casey Schaufler wrote:
>>>>>>>> >On 11/29/2012 4:46 PM, David Quigley wrote:
>>>>>>>> >>On 11/29/2012 19:34, Casey Schaufler wrote:
>>>>>>>> >... Whole bunch snipped ...
>>
>> Looks like Smack requires CAP_MAC_ADMIN in order to set Smack
>> attributes on a file at all.  So nfsd would require that capability
>> for Smack.  I think this means however that setting Smack labels on
>> NFS files won't work in any case where root is squashed, which seems
>> unfortunate.

I'm building a kernel with CAP_MAC_ADMIN set for nfsd.
I am reasonably sure that this will get me past the current
issue. As far as a squashed root goes, well, doing things
that the security policy doesn't allow requires privilege.

>
> I'll leave that problem to Casey to figure out. However it seems to me
> that regardless of Labeled NFS Casey should have problems with the NFS
> server not being able to serve up files that are dominated by floor. I
> wonder if he has every tried NFSv4 on a SMACK enabled server before.
> It may have just worked because all files implicitly get labeled floor.

CAP_MAC_OVERRIDE, which nfsd does have, is sufficient for
reading and writing files. A Smack enabled server is able
to serve to Smack and Smackless clients, but of course all
label enforcement is lost. Thus it will "work", but it will
be bad. I haven't used NFS much lately, in part because of
the lack of labeling and the security issues inherent in
serving labeled files to clueless clients. 


>
>>
>> On the SELinux side, we don't require CAP_MAC_ADMIN to set the
>> SELinux attribute on a file in the normal case, only when the SELinux
>> attribute is not known to the security policy yet.  So granting
>> CAP_MAC_ADMIN there means that a client will be able to set security
>> contexts on files that are unknown to the server.  I guess that might
>> even be desirable in some instances where client and server policy are
>> different.  We do have the option of denying mac_admin permission in
>> policy for nfsd (kernel_t?), in which case we would block such
>> attempts to set unknown contexts but would still support setting of
>> known security contexts.
>>
>> So I think it is workable, albeit a bit confusing.
>
> Yea it is unfortunate that we have to go mucking around in capability
> land but it seems that adding CAP_MAC_ADMIN should be fine and we can
> deal with it in policy if we like.

Worst case we could add a security_set_nfsd_capabilities hook.
Maybe make the capability set an export option?

>
>
> -- 
> This message was distributed to subscribers of the selinux mailing list.
> If you no longer wish to subscribe, send mail to
> majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.
>

