Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31625 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755052Ab3KTUff convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 15:35:35 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "<steved@redhat.com>" <steved@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
Date: Wed, 20 Nov 2013 20:35:34 +0000
Message-ID: <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
 <1382454148.9794.72.camel@willson.li.ssimo.org>
 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
 <1382458162.9794.85.camel@willson.li.ssimo.org>
 <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
 <1382462720.9794.131.camel@willson.li.ssimo.org>
In-Reply-To: <1382462720.9794.131.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

As suggested, I approached the Kerberos@mit.edu about the possibility of a plugin architecture for libkrb5 credential cache manipulation functions so that we could trigger the kernel GSS_context management functions.

On Nov 19, 2013, at 2:46 PM, Greg Hudson <ghudson@MIT.EDU> wrote:

> On 11/15/2013 12:12 PM, Adamson, Andy wrote:
>> Solution 1: [inotify on FILE credentials]
>> Solution 2: [integrate with KEYRING credentials]
>> Solution 3: [nfslog/nfslogout interfaces invoked from PAM or other login system facility]
>> Solution 4: AFAICS the most versatile solution is to add a plugin architecture to libkrb for call
>> outs on functions that manipulate kerberos credentials.
> 
> I agree that solution 1 isn't great.
> 
> I have concerns about solution 4.  Kerberos credential caches can be
> used for several different purposes; they aren't only used to store
> login credentials.  For instance, a user could run a server process
> which receives delegated credentials from a client, or could run kadmin
> and get credentials for username/admin to administer the realm's KDB.
> Notifying the kernel any time any credential cache is destroyed would
> create a lot of false positives.
> 
> I would be happy to have a pluggable interface which allows for
> implementations of new ccache types, but I don't think I would welcome a
> hook-style interface which causes ccache operations to have arbitrary
> side effects beyond changing the ccache.
> 
> I don't know enough about the Linux kernel to comment on whether
> solution 2 is viable.  Solution 3 is obviously viable in the sense that
> we're used to it with AFS.
> 


It appears that Solution 4: [plugin architecture to libkrb for callouts on functions that manipulate kerberos credentials.] is a no-go. 

I agree that Solution 1: [inotify on FILE credentials] is clunky and won't work well.

Solution 2: [integrate with KEYRING credentials] could work if we insist that all NFS Kerberos credentials use the KEYRING: - e.g. the proposed new 'big-key' type. Note there is no backporting of this solution.

I think Solution 3: [nfslog/nfslogout interfaces invoked from PAM or other login system facility] is a good way to go.  Note that a PAM based solution where in the PAM would get us most of the way towards providing users with a way to login and logout of NFS kerberized shares.

Comments on an NFS PAM that will destroy GSS context for a UID upon logout?

Simo - I answered your latest comments below in-line.

On Oct 22, 2013, at 1:25 PM, Simo Sorce <simo@redhat.com> wrote:

> On Tue, 2013-10-22 at 17:00 +0000, Adamson, Andy wrote:
>> On Oct 22, 2013, at 12:09 PM, Simo Sorce <simo@redhat.com>
>> wrote:
>> 
>>> On Tue, 2013-10-22 at 15:32 +0000, Adamson, Andy wrote:
>>>> On Oct 22, 2013, at 11:02 AM, Simo Sorce <simo@redhat.com> wrote:
>>>> 
>>>>> On Tue, 2013-10-22 at 10:22 -0400, andros@netapp.com wrote:
>>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>> 
>>>>>> This is an RFC patchset, which will be used for testing.
>>>>>> 
>>>>>> This patchset requires the "SUNRPC: destroy gss_cred and context on Kerberos credential destruction" kernel patchset.
>>>>>> 
>>>>>> We need to do a lot of testing to ensure that once kdestroy and gss-ctx
>>>>>> gss_user_destroy is called, all existing buffered
>>>>>> writes using the 'destroyed gss credential + context' are serviced.
>>>>>> 
>>>>>> Differences from version 1:
>>>>>> 
>>>>>> - moved from nfstgt_login and nfstgt_logout to gsskeyd.
>>>>>> - gsskeyd automatically creates gss-ctx key on kinit and destroys the gss-ctx
>>>>>> key on kdestroy.
>>>>>> 
>>>>>> gsskeyd will need to act differently for different krb5 credential caches.
>>>>> 
>>>>> Why ?
>>>> 
>>>> Just need different parsing to know which directory to poll. 
>>>>> 
>>>>>> For example, some versions of gssd store FILE credentials in FILE:/tmp/krb5cc_<UID>
>>>>>> while this code, written for fedora 19 uses FILE:/run/user/<UID>/krb5cc/tgt.
>>>>> 
>>>>> This is incorrect, Fedora 19 use DIR type ccaches, so you should
>>>>> reference a cache withing the dir type, which will notmally be something
>>>>> like: DIR:/run/user/<uidnumber>/krb5cc for the whole collection or
>>>>> DIR::/run/user/<uidnumber>/krb5cc/txtXXXXXX for the sepcific cache.
>>>>> 
>>>>> However note that due to issues with DIR type caches we are moving to a
>>>>> new KEYRING based type of cache in F20, so assuming any specific type of
>>>>> cache is a dead start.
>>>> 
>>>> But I'm not assuming any kind of kerberos credential cache! I just coded to one type for this RFC.
>>>> Didn't you see my KEYRING based ccache comment below?
>>> 
>>> Ah sorry, I had not noticed.
>>> 
>>>>>> As Trond suggested, if we keep gsskeyd separate from gssd, we could set up a
>>>>>> configuration file along the lines of the keytools' request-key.conf file to
>>>>>> allow both NFS and CIFS (and other filesystems) to install plugin handlers
>>>>>> for kinit/kdestroy events.
>>>>> 
>>>>> Given in many cases (the desirable ones at least) kerberos credentials
>>>>> are not inited via kinit, but rather by things like pam_krb5, sssd, or
>>>>> directly imported via sshd, I am trying to understand how you are going
>>>>> to address the majority of these cases.
>>>> 
>>>> All of these cases use a kerberos credential cache which if is of type
>>>> FILE the gsskeyd can poll inotify and if it is of type KEY: then
>>>> gsskeyd adds the gss-ctx key to the Kerberos keyring (that is the
>>>> theory :)) so the same code services kinit/pam_krb5
>>> 
>>> You wouldn't be able to see it if I set a custom ccache file though
>>> export KRB5CCNAME=FILE:/random/sir/foofile
>>> 
>>>>> Should users put gsskeyd in their .profile/.bashrc files or something ?
>>>>> 
>>>>>> Else, we could have gssd be the process to poll inotify (given
>>>>>> that it already polls rpc_pipefs) and then just have it fork off the
>>>>>> subprocess if and when it sees an interesting event.
>>>>> 
>>>>> What is an 'interesting' event ?
>>>> 
>>>> TGT (used for NFS TGS) creation/destruction
>>> 
>>> Shouldn't you care for the specific NFS ticket only ?
>>> Although kdestroy is quite blunt, in theory users can simply destroy the
>>> specific NFS ticket and keep their TGT.
>> 
>> AFAICS MIT kdestroy does not let you specifiy which credentials to
>> destroy. It simply destroys the whole specified ccache, TGT and all.
>> 
>> I think Heimdal kdestroy lets you specify...
>> 
>> WRT NFS: As long as the TGT has not expired, the kernel will upcall
>> and GSSD will get a new TGS.  So, the kernel gss_context lifetime ==
>> TGT lifetime.
>> 
>> The solution with the current MIT kdestroy is to have a NFS-only
>> kerberos credentail cache - with it's own TGT and only NFS TGS's.
> 
> There isn't just kdestroy, applications can use libkrb5 to manipulate
> the ccache if needed. I am just pointing out that there are many ways
> ccaches are manipulated in real life.
> 
> I think it is valuable to be able to invalidate the credentials in the
> kernel when the user really wants it, I just think that guessing when
> the user/admin wants you to drop the creds based on ccaches interactions
> is probably not going to work very well.

I think a PAM based solution will get us most of the way there.

> 
> So the way I see it you probably want to keep the tracking in whatever
> tool you want to use to experiment (say gsskeyd) and only provide a
> downcall to the kernel that will tell it: destroy any cache for 'uid
> number (optionally pass in a session id too ?)'.

This is what the gss-ctx keyring destroy method is - a downcall to the kernel telling it to destroy all GSS_contexts for a UID.

> 
> This way you can replace the logic of how to keep track of what is going
> on completely in user space, where it can easily be adjusted and adapted
> as experience is gained.
> 
> IE: track it completely in userspace for now and only provide a syscall
> to kill creds per UID, no tracking on the kernel side.

Yes - I believe that is what the gss-ctx keyring code I wrote does.

-->Andy

> 
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 

