Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:40437 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753813Ab3JVRAC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 13:00:02 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "<steved@redhat.com>" <steved@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
Date: Tue, 22 Oct 2013 17:00:01 +0000
Message-ID: <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
 <1382454148.9794.72.camel@willson.li.ssimo.org>
 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
 <1382458162.9794.85.camel@willson.li.ssimo.org>
In-Reply-To: <1382458162.9794.85.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 22, 2013, at 12:09 PM, Simo Sorce <simo@redhat.com>
 wrote:

> On Tue, 2013-10-22 at 15:32 +0000, Adamson, Andy wrote:
>> On Oct 22, 2013, at 11:02 AM, Simo Sorce <simo@redhat.com> wrote:
>> 
>>> On Tue, 2013-10-22 at 10:22 -0400, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>> 
>>>> This is an RFC patchset, which will be used for testing.
>>>> 
>>>> This patchset requires the "SUNRPC: destroy gss_cred and context on Kerberos credential destruction" kernel patchset.
>>>> 
>>>> We need to do a lot of testing to ensure that once kdestroy and gss-ctx
>>>> gss_user_destroy is called, all existing buffered
>>>> writes using the 'destroyed gss credential + context' are serviced.
>>>> 
>>>> Differences from version 1:
>>>> 
>>>> - moved from nfstgt_login and nfstgt_logout to gsskeyd.
>>>> - gsskeyd automatically creates gss-ctx key on kinit and destroys the gss-ctx
>>>> key on kdestroy.
>>>> 
>>>> gsskeyd will need to act differently for different krb5 credential caches.
>>> 
>>> Why ?
>> 
>> Just need different parsing to know which directory to poll. 
>>> 
>>>> For example, some versions of gssd store FILE credentials in FILE:/tmp/krb5cc_<UID>
>>>> while this code, written for fedora 19 uses FILE:/run/user/<UID>/krb5cc/tgt.
>>> 
>>> This is incorrect, Fedora 19 use DIR type ccaches, so you should
>>> reference a cache withing the dir type, which will notmally be something
>>> like: DIR:/run/user/<uidnumber>/krb5cc for the whole collection or
>>> DIR::/run/user/<uidnumber>/krb5cc/txtXXXXXX for the sepcific cache.
>>> 
>>> However note that due to issues with DIR type caches we are moving to a
>>> new KEYRING based type of cache in F20, so assuming any specific type of
>>> cache is a dead start.
>> 
>> But I'm not assuming any kind of kerberos credential cache! I just coded to one type for this RFC.
>> Didn't you see my KEYRING based ccache comment below?
> 
> Ah sorry, I had not noticed.
> 
>>>> As Trond suggested, if we keep gsskeyd separate from gssd, we could set up a
>>>> configuration file along the lines of the keytools' request-key.conf file to
>>>> allow both NFS and CIFS (and other filesystems) to install plugin handlers
>>>> for kinit/kdestroy events.
>>> 
>>> Given in many cases (the desirable ones at least) kerberos credentials
>>> are not inited via kinit, but rather by things like pam_krb5, sssd, or
>>> directly imported via sshd, I am trying to understand how you are going
>>> to address the majority of these cases.
>> 
>> All of these cases use a kerberos credential cache which if is of type
>> FILE the gsskeyd can poll inotify and if it is of type KEY: then
>> gsskeyd adds the gss-ctx key to the Kerberos keyring (that is the
>> theory :)) so the same code services kinit/pam_krb5
> 
> You wouldn't be able to see it if I set a custom ccache file though
> export KRB5CCNAME=FILE:/random/sir/foofile
> 
>>> Should users put gsskeyd in their .profile/.bashrc files or something ?
>>> 
>>>> Else, we could have gssd be the process to poll inotify (given
>>>> that it already polls rpc_pipefs) and then just have it fork off the
>>>> subprocess if and when it sees an interesting event.
>>> 
>>> What is an 'interesting' event ?
>> 
>> TGT (used for NFS TGS) creation/destruction
> 
> Shouldn't you care for the specific NFS ticket only ?
> Although kdestroy is quite blunt, in theory users can simply destroy the
> specific NFS ticket and keep their TGT.

AFAICS MIT kdestroy does not let you specifiy which credentials to destroy. It simply destroys the whole specified ccache, TGT and all.

I think Heimdal kdestroy lets you specify...

WRT NFS: As long as the TGT has not expired, the kernel will upcall and GSSD will get a new TGS.  So, the kernel gss_context lifetime == TGT lifetime.

The solution with the current MIT kdestroy is to have a NFS-only kerberos credentail cache - with it's own TGT and only NFS TGS's.

-->Andy



> 
> Also I see a problem with this approach. In order to make user life
> easier we reinit ccaches in sssd when a user for example unlocks the
> screen. If you track a specific TGT or NFS ticket, this would cause the
> immediate destruction of credentials in the nfs client which will also
> kill access to the NFS server. I think this would cause quite some grief
> to users.
> 
>>>> We need to investigate how this works when the kernel keyring is used for
>>>> Kerberos credentials. I believe that in this case gsskeyd can add the gss-ctx
>>>> key to the kerberos keyring, and it will get destroyed along with all other
>>>> keys at kdestroy.
>>> 
>>> Is there any reason why you are doing this work with an utility that is
>>> separate from gssd or libkrb5 ?
>> 
>> Yes  - to allow both NFS and CIFS (and other filesystems) to install
>> plugin handlers for kerberos credential cache creation/destruction
>> events.
>> 
>> But, having gssd do it is fine, or having a client plugin in libkrb5
>> is also fine.
> 
>>> 
>>> I think the only sensible way to handle something like this is by adding
>>> support directly in libkrb5, I do not see something external ever
>>> working reliably.
>> 
>> I agree that I should persue a libkrb5 approach.
> 
> Keep in mind the point above though.
> The issues here is that you do not know what the intention was if you
> try a completely automated approach. you should probably interact with
> the login service and act conditionally in any way.
> 
> I think it may be safer for you to provide a hook that the system can
> call when a user fully logs out. And use that hook to kill any
> credential associated to a particular UID.
> 
> Done this way you do not need to poll anything nor change libkrb5. And
> you also allow the creation of a tool that the user can run to force the
> destruction of his credentials if he is not using a compliant login
> manager. Or if he wants to explicitly kill NFS creds in the kernel for
> whatever reason.
> 
>>> I am not against it for testing purposes, but then does it need to be
>>> committed to nfs-utils ?
>> 
>> Did you not see the "This is an RFC patchset"? I'm not asking for a commit to nfs-utils, but "request for comments" which you just did!  Thanks :)
> 
> Yes I was providing feedback :-)
> 
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 

