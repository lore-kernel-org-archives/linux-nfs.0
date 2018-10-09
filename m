Return-Path: <language.lawyer@gmail.com>
Subject: Re: Kernel NFS client and Kerberos delegation
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <6369655a-a0b0-5c3c-7c68-b623a4270668@gmail.com>
 <A418C8F8-0189-4959-9E29-862095728028@redhat.com>
From: Language Lawyer <language.lawyer@gmail.com>
Message-ID: <54608c44-a30b-8e16-9a22-e7e1183a0feb@gmail.com>
Date: Tue, 9 Oct 2018 16:44:40 +0300
MIME-Version: 1.0
In-Reply-To: <A418C8F8-0189-4959-9E29-862095728028@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
List-ID: <linux-nfs.vger.kernel.org>

On 09/10/18 16:11, Benjamin Coddington wrote:
> On 8 Oct 2018, at 15:46, Language Lawyer wrote:
> 
>> Hi,
>>
>> AFAIU kernel NFS client keeps ID -> Name mapping in the "id_resolver"
>> keyring.  Do I understand it correctly that with this hard mapping it is
>> not possible for a service to access a kerberized NFS storage on behalf of
>> some user using user's delegated (for example, with S4U2Self+S4U2Proxy)
>> credentials?
> 
> The id_resolver keyring exists to translate kerberos principles to UID and
> the reverse, but it doesn't really play in the mechanisms that you're
> interested in.
> 
> I assume you want a particular process, like httpd, to have the kernel chose
> which kerberos principle and thus which GSS context to use when sending RPC
> to the NFS server.
> 
> The NFS client will choose the appropriate GSS context based on the fsuid of
> the calling process, and then as long as the gssd daemon can find an
> appropriate kerberos cache and establish a context everything will work
> fine.  So, as long as your service changes its fsuid (like smbd does),
> everything generally works.

Yes, currently one has to grant CAP_SETUID capability to a service and
setup a way to obtain appropriate ticket, for example, by giving gssproxy
permission to impersonate users, instead of just granting a service
permission to impersonate users.

> If you want a process that doesn't change its fsuid to use a different GSS
> context, you have to find a way to communicate which context, or credential
> you want the kernel to choose.
Are there plans to support this in the kernel NFS client?
