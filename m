Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53959 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab0KAXrR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Nov 2010 19:47:17 -0400
Received: by mail-iw0-f174.google.com with SMTP id 10so7645331iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Nov 2010 16:47:17 -0700 (PDT)
In-Reply-To: <4CCA8863.6040505@agorabox.org>
References: <4CCA8863.6040505@agorabox.org>
Date: Mon, 1 Nov 2010 19:47:16 -0400
Message-ID: <AANLkTi=weMaggLo_d12_aXgavSmzq+OYprhUHNXmWDo2@mail.gmail.com>
Subject: Re: rpc.gssd and proxiable/forwardable tickets.
From: Kevin Coffman <kwc@citi.umich.edu>
To: Marc Schlinger <marc.schlinger@agorabox.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Marc,
This sounds like a bug.  This should be considered a valid credentials
cache (without a TGT).  I don't have the cycles to attempt a fix, nor
am I sure what the correct fix would be.  I hope someone else does!

K.C.

On Fri, Oct 29, 2010 at 4:40 AM, Marc Schlinger
<marc.schlinger@agorabox.org> wrote:
>
> Hello,
>
> I'm using WebAuth to authenticate my user and provide them a mean to
> join their NFSv4 files through a web page.
> I'd  like to have the kerberos credentials used by the web server, but I
> didn't managed to impersonate the kerberos user with nfsv4 in a webauth
> protected page.
> When I try to list the an nfs directory  from the webpage I've got this
> error from rpc.gssd:
>
> CC file '/tmp/krb5cc_500' is expired or corrupt
>
> My distribution is Fedora 12 and i'm using nfs-utils 1.2.1.
>
> WebAuth is configured to ask the client a forwardable ticket for
> nfs/<mynfsserver>@<myrealm>. In my application's code I can see the
> ticket and even do a klist with it. The output looks like this:
>
> $ klist
> Ticket cache: FILE:/tmp/krb5cc_500
> Default principal: marc@<myrealm>
>
> Valid starting     Expires            Service principal
> 10/28/10 20:15:17  10/29/10 20:15:15  nfs/<mynfsserver>@<myrealm>
>    Flags: FAT
>
> So my application never gets the krbtgt tickets. Considering security, I
> believe this is a good point.
>
> I must confess that I didn't manage to follow rpc.gssd process with gdb
> or with ltrace.
> So until I'm able to trace gssd execution all things that follows are
> pure suppositions.
>
>
> While trying to find a valid credential_cache gssd calls a function in
> utils/krb5_utils.c, "check_for_tgt", that does this loop:
>
>    while (!found&&   (ret = krb5_cc_next_cred(context, ccache,&cur,
> &creds)) == 0) {
>        if (creds.server->length == 2&&
>                data_is_equal(creds.server->realm, principal->realm)&&
>                creds.server->data[0].length == 6&&
> ->              memcmp(creds.server->data[0].data, "krbtgt", 6) == 0&&
>                data_is_equal(creds.server->data[1], principal->realm)&&
>                creds.times.endtime>   time(NULL))
>            found = 1;
>        krb5_free_cred_contents(context,&creds);
>    }
>
>
> What I understand is that without a krbtgt entry, a credential cache
> will be considered invalid.
>
> Is there some reasons for this?
> For what I've understand about kerberos protocol, a proxiable or
> forwardable service ticket is sufficient to communicate with the nfs
> server. But I may be wrong.
>
>
> Thanks for your help.
>
> Marc Schlinger
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
