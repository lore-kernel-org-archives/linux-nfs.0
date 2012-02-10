Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:53467 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759617Ab2BJSTI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 13:19:08 -0500
Received: by wics10 with SMTP id s10so2215612wic.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Feb 2012 10:19:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120210172554.5e89e364@little-poseidon>
References: <20120210154526.7b504146@little-poseidon>
	<CAHVgHyUdxUhg3rBHNzf3EX049iqU-Mm2WiCtpAzz3v_yn1J7sQ@mail.gmail.com>
	<20120210172554.5e89e364@little-poseidon>
Date: Fri, 10 Feb 2012 13:19:06 -0500
Message-ID: <CAHVgHyWYpbuAZ9SFk+oiQmStQC4cnr+yGPvdjag3zT61Cj0KxA@mail.gmail.com>
Subject: Re: mount hangs in NFS4+Kerberos setup
From: Andy Adamson <androsadamson@gmail.com>
To: whats_up@gmx.net
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 10, 2012 at 11:25 AM,  <whats_up@gmx.net> wrote:
>
>> Hi
>>
>> It appears that the RPCSEC_GSS Kerberos calls were successful, but
>> that the Kerberos principal to id mapping failed.
>
> Is this influenced by /etc/idmapd.conf?

Yes. libnfsidmapd.023 nss_gss_princ_to_id checks the Kerberos REALM
passed in the sname against the configured REALMS in /etc/idmapd.conf
as explained:




[General]
#Verbosity = 0
# The following should be set to the local NFSv4 domain name
# The default is the host's DNS domain name.
#Domain = local.domain.edu

# The following is a comma-separated list of Kerberos realm
# names that should be considered to be equivalent to the
# local realm, such that <user>@REALM.A can be assumed to
# be the same user as <user>@REALM.B
# If not specified, the default local realm is the domain name,
# which defaults to the host's DNS domain name,
# translated to upper-case.
# Note that if this value is specified, the local realm name
# must be included in the list!
#Local-Realms =


I believe you have not set the Local-Realms, so libnfsidmapd.023 uses
the default of the upper-case of the local domain-name. Thus the
nss_gss_print_ids error message:

> Feb 10 14:45:17 tm rpc.svcgssd[1335]: nss_gss_princ_to_ids: Local-Realm '<MYREALM>': NOT FOUND

Try setting the Local-Realms =  in /etc/idmapd.conf.

-->Andy


>  I played with "Domain" and
> "Local-Realm" but I didn't understand the exact meaning. Server and
> client aren't in the same subdomain:
> server:  hostname.subdomain.domain.tld
> client:  hostname.subdomain.subdomain.domain.tld
> Is this a problem?
>
>> What kernel is the server running?
>> What nfs-utils version is the server using?
>> What libnfsidmap version is the server using?
>
> I'm using Debian squeeze with updates.
>
> $ uname -a
> Linux tm 2.6.32-5-686 #1 SMP Mon Jan 16 16:04:25 UTC 2012 i686 GNU/Linux
>
> $ dpkg -l nfs-\*
> un  nfs-client                             <none>                                 (no description available)
> ii  nfs-common                             1:1.2.2-4squeeze2                      NFS support files common to client and server
> ii  nfs-kernel-server                      1:1.2.2-4squeeze2                      support for NFS kernel server
> un  nfs-server                             <none>                                 (no description available)
>
> $ dpkg -l libnfsidmap\*
> un  libnfsidmap1                           <none>                                 (no description available)
> ii  libnfsidmap2                           0.23-2                                 An nfs idmapping library
>
>
> regards
>  knut
