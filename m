Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:29240 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbZAEVyB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 16:54:01 -0500
Cc: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org
Message-Id: <4F34D959-E087-4736-A00A-49F75708F1C5@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <496268F9.8010607@RedHat.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH] gssd: By default, don't spam syslog when users' credentials expire
Date: Mon, 5 Jan 2009 16:53:05 -0500
References: <20081217173927.3031.53736.stgit@jazz.citi.umich.edu> <496268F9.8010607@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 5, 2009, at Jan 5, 2009, 3:09 PM, Steve Dickson wrote:
> Kevin Coffman wrote:
>> Change the priority of "common" log messages so that syslog doesn't  
>> get
>> slammed/spammed when users' credentials expire, or there is another  
>> common
>> problem which would cause error messages for all context creation  
>> requests.
>>
>> Note that this will now require that gssd or svcgssd option "-v" is  
>> used to
>> debug these common cases.
>>
>> Original patch from Andrew Pollock <apollock@google.com>.
>>
> Committed...
>
> This took a little longer than expected do to a fairly
> nasty bug in the Fedora 10 installation....
>
> The installation process adds both the FQDN and the host name
> (i.e. the non-FQDN) to the 127.0.0.1 line in /etc/hosts. This
> causes gethostname() on the FQDN to return 127.0.0.1 instead of
> DNS IP address... This caused svcgssd to always fail due to
> the host name not being found in the key tab.
>
> Unfortunately it took quite a bit to figure out what host name the
> kerberos libs were looking since the host name in the key tab was
> indeed correct... That lib code is definitely lacking when it comes
> to debug-ability... :-(
>
> So buyer bewared... if you recently installed F-10 please check to see
> if your /etc/hosts file only contains the non-FQDN host name on the
> 127.0.0.1 line.

I think that's the default configuration for F10 (and probably earlier  
Fedora releases as well).  The lack of proper /etc/hosts entries also  
wreaks some havoc with sendmail.

Moreover, F10's Anaconda no longer allows you to specify a static IP  
configuration at install time -- network configuration is handled  
almost entirely via NetworkManager, and any special configuration,  
other than "use DHCP for every network interface you can find," is now  
done after the system is installed and running.

F10 still includes system-config-network and /etc/init.d/network, but  
these are unused/disabled by default.  system-config-network doesn't  
play well with NetworkManager.  There's also no way to specify a fixed  
IPv6 address.

While this automatic style of network configuration matches the trend  
set by Ubuntu, and probably meets the needs of most desktop users, I  
find it pretty inconvenient for servers (which is mostly how I  
configure and use Linux these days).

I would like either a restoration of networking configuration during  
the installation process, or to have the network management tools work  
and have decent help facilities and wizards.  Even better if we could  
have both.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
