From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: NFSv4, MIT KRB5, home-directory permissions
Date: Tue, 3 Jun 2008 12:40:03 -0400
Message-ID: <4d569c330806030940j2c3e366fp1498b8c189d6e0b5@mail.gmail.com>
References: <20080603115721.GA27052@netwichtig.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Hendrik Jaeger" <hank-BuXUH66JCJPEZGwTFP6sgQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:25490 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbYFCQkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2008 12:40:06 -0400
Received: by ti-out-0910.google.com with SMTP id b6so565097tic.23
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jun 2008 09:40:04 -0700 (PDT)
In-Reply-To: <20080603115721.GA27052-BuXUH66JCJPEZGwTFP6sgQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By default, the machine credentials are used for mount (and any file
access done by root).  The testuser needs to have their own Kerberos
credentials.  I can't think of any work-around to that.

K.C.

On Tue, Jun 3, 2008 at 7:57 AM, Hendrik Jaeger <hank-BuXUH66JCJPEZGwTFP6sgQ@public.gmane.org> wrote:
> Hi,
>
> I have a problem with my setup. In the end it should work like this:
> - Users are in LDAP, including their passwords
> - Homedirectories are mounted via NFSv4 on the clients
> - client-machines are authenticated to the NFS-Server via MIT Kerberos
> - Users are authenticated via libpam-ldap
>
> Most of that is already working and IIRC i already had everything
> working when i tried it some time ago, but now i can't figure out, what
> i did wrong this time.
>
> What I have:
> - 1 machine running slapd, nfs-kernel-server and MIT Kerberos v5 (FQDN
>        is server.bws.example)
> - 1 machine acting as client (FQDN is client.bws.example)
> - 1 User in the ldap tree called 'testuser' with homedirectory set to
>        /home/nfs/testuser
> - 1 export on the server:
>        /srv/nfs *(rw,sync,fsid=0,sec=krb5p)
> - 1 nfs4 mount on the client
>        server.bws.example:/ /home/nfs nfs4 sec=krb5p 0 0
> - 2 principals: nfs/server.bws.example and nfs/client.bws.example
>        each of those has been exported and put in the /etc/krb5.keytab on the
>        corresponding machine
> - on both machines matching lines in /etc/hosts:
>        192.168.0.1 server.bws.example server
>        192.168.0.2 client.bws.example client
>
> What works:
> - testuser can log in on the client
> - /home/nfs can be mounted on the client
> - ls -ld /home/nfs/testuser as root shows the directory belonging to
>        testuser:testuser with permissions 755
>
> What does not:
> - testuser can't get to his own homedirectory. he gets a 'permission
>        denied' when trying to access /home/nfs
>
> syslog on the client:
> rpc.gssd: ERROR: GSS-API: error in gss_acquite_cred(): Unspecified GSS
> failure. Minor code may provide more information - No credentials cache
> found
> rpc.gssd: WARNING: Failed to create krb5 context for user with uid 10000
> for server server.bws.example
>
> This looks to me like 'testuser' should have a principal in kerberos to
> use the nfs-mount.
>
> Is there a possibility to just make the machines authenticate each other
> for the nfs mount and NOT need every single user in kerberos as well?
> AFAIR i had a setup like this only some weeks ago, but i'm not able to
> reproduce it.
>
> Any help with this is appreciated. Since i am not subscribed to the list
> (yet) please CC me.
>
> If you need any more information please ask.
>
> Thanks in advance!
>
> Hendrik Jaeger
>
>
>
> --
> Slang is language that takes off its coat, spits on its hands, and goes to work.
>
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.6 (GNU/Linux)
>
> iD8DBQFIRTGh5PO/ypkUBC8RAhDfAKCsy/4gpaCcEnujr1sm1zEwDOJkkwCgjLu6
> +77cu93MYSruEItZRPwQztk=
> =L/jq
> -----END PGP SIGNATURE-----
>
>
