Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:40796 "HELO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752776Ab2KUCwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2012 21:52:14 -0500
Message-ID: <50AC41DC.5070607@schaufler-ca.com>
Date: Tue, 20 Nov 2012 18:52:12 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
MIME-Version: 1.0
To: Dave Quigley <dpquigl@davequigley.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <50ABF1A5.2010406@schaufler-ca.com> <50AC1A74.7080105@davequigley.com> <50AC2117.801@schaufler-ca.com> <50AC224D.3080108@davequigley.com>
In-Reply-To: <50AC224D.3080108@davequigley.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/20/2012 4:37 PM, Dave Quigley wrote:
> ...
>
>
> Or I could just give you this link and you should be good to go ;)
>
> http://www.selinuxproject.org/~dpquigl/nfs-utils-rpms/
>
> I haven't tried it but it should work. If it doesn't let me know and
> i'll try to fix it on my end. I'd imagine you might need to yum remove
> nfs-utils first before adding this new one or you could also try an
> rpm with the upgrade flag for this instead. Good luck.

I don't care what Eric says, you're OK with me.

The behavior is interesting with a Smack kernel:

I create an export using the recommended options (sec=unix,security_label, ...)
of /pub. Then , I create a directory sub with the floor ("_") label and a file
named Pop labeled "Pop". I mount the filesystem at /mnt.

# ls -l /mnt
ls: cannot access /mnt/Pop: Permission Denied
total 4
?????????? ? ?    ?       ?            ? Pop
drwxr-xr-x 2 root root 4096 Nov 20 17:57 sub

which is exactly correct!

Unfortunately, I get the exact same result if the process
is run with the Pop label. A process run with the Pop label
should be able to see the attributes of the file Pop.

It looks as if the basic mechanism is working, but that there
is some detail that is not working right. I will have to dig
deeper to understand what's up. Let me know if you have ideas.


>
> Dave
>
> -- 
> This message was distributed to subscribers of the selinux mailing list.
> If you no longer wish to subscribe, send mail to
> majordomo@tycho.nsa.gov with
> the words "unsubscribe selinux" without quotes as the message.
>

