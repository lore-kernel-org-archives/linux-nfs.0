Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:55941 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab2BJSH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 13:07:26 -0500
Message-ID: <4F355CD2.6040603@steve-ss.com>
Date: Fri, 10 Feb 2012 19:07:14 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: whats_up@gmx.net
CC: linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
References: <20120210154526.7b504146@little-poseidon> <4F35512A.9050500@steve-ss.com> <20120210184154.03fb6907@little-poseidon>
In-Reply-To: <20120210184154.03fb6907@little-poseidon>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/10/2012 06:41 PM, whats_up@gmx.net wrote:
>
>> Some older kernels do not support strong keys. Try adding:
>> allow_weak_crypto = true
>> to the
>>    [libdefaults]
>> in /etc/krb5.conf
> yes. I painfully (mount only says access denied) found out this already
> and I use allow_weak_crypto to limit to DES. More encryption
> types have been introduced with kernel 2.6.39...
>
> I tried to use kernel 3.2 from squeeze-backports but this introduced new
> errors, thus I decided to try with 2.6 first.
>
>
>> Also it's not recommended to use the pseudo-root fsid=0 method for
>> nfs exports under Linux:
>>    http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration
> hmm, as far as I have understood I have to:
> - export the root folder /exports explicitly beside the "real"
>    exports p.ex. /exports/opt
> - use fsid=0 for the root folder to force version 4 of NFS
>
> What's your suggestion to improve/secure my configuration?
>
> regards
>    knut
Officially, you should not export from a pseudo root. Please see the 
last few lines in the link I sent.
man rpc.gssd(8) adds:
<quote>
Previous versions of
rpc.gssd used only "nfs/*" keys found within the keytab. To be more 
consistent with other implementations, we now look for specific keytab 
entries. The search order for keytabs to be used for "machine 
credentials" is now:
<HOSTNAME>$@<REALM>
root/<hostname>@<REALM>

nfs/<hostname>@<REALM>

host/<hostname>@<REALM>

root/<anyname>@<REALM>

nfs/<anyname>@<REALM>

host/<anyname>@<REALM>
</quote>

I see your setup uses the root principal. If you still get access 
denied, create another keytab with just the machine$ and host/fqdn keys. 
I can remember having to fiddle with nfs-utils and keytabs on openSUSE 
at some stage last year.

If none of this works you can either stick with the old kernel and 
accept he security, get an up to date nfs-utils and see if hat fixes it 
with the DES keys or grab an up to date distro where all this stuff will 
work out of the box.
Cheers,
Steve

