Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687AbaBCVB3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Feb 2014 16:01:29 -0500
Message-ID: <52F003A1.3060908@RedHat.com>
Date: Mon, 03 Feb 2014 16:01:21 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown>
In-Reply-To: <20140130172451.7a354ce4@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/30/2014 01:24 AM, NeilBrown wrote:
> 
>  So:
>   1/ Do you agree that a collection of systemd unit files belongs in
>      nfs-utils?
I think having a single way to start NFS across all distors would be
a very good thing... 

>   2/ Do you think it reasonable to expect most (systemd using) distros to
>      use the one set?  I will certainly try to ensure openSUSE does if
>      upstream accepts them.
I think I'll already agreed to this as well... 

>   3/ Do you have any comments/question about those below?
I took a little closer look at these and actual tried to 
get them to work in a Fedora environment. Here is what I found..


> diff --git a/systemd/README b/systemd/README
> new file mode 100644
> index 000000000000..f0fb68825499
> --- /dev/null
> +++ b/systemd/README
> @@ -0,0 +1,50 @@
> +
> +Notes about systemd unit files for nfs-utils.
> +
> +The unit files provided here should be sufficient for systemd
> +to manage all daemons and related services provides by nfs-utils.
> +
> +They do *not* include any unit files for separate services such as
> +rpc.rquotad (in the 'quota' package) or rpcbind.
> +
> +There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
> +by a suitable 'preset' setting:
> +
> + nfs-server.target
> +    If enabled, nfs service is started together with dependencies
> +    such as mountd, statd, rpc.idmapd
This changes the current API... Today to enable/start this service 
today one does:

  systemctl enable nfs-server
  systemctl start nfs-server

which would change to:

  systemctl enable nfs-server.target
  systemctl start nfs-server

with the same daemons being started.
This changed will cause existing scripts to fail... 
I guess I don't see the point of having a .target file. 

How is rpc.svcgssd enabled? Since the .service file does
not have a [Install] section the systemctl enable rpc.svcgssd
fails.

Also how does gss-proxy come to play in all this? Maybe we 
just use  gss-proxy by default and retire rpc.svcgssd.

> +
> + nfs-client.target
> +    If enabled, daemons needs for an nfs client are enabled.
> +    This does *not* include rpc.statd.  the rpc-statd.service unit
> +    is started by /usr/sbin/start-statd which mount.nfs will run
> +    if statd is needed.
I am coming around to liking this one... but I think it should start
statd and configure lockd. Why not just roll the current nfs-lock 
service under this umbrella? A simple systemctl restart nfs-client
would configure and start all of the needed daemons. 

How would these daemons be restart and shutdown? Since this is a 
target, systemctl restart and system stop don't do anything.

> +
> + nfs-secure.target
> +    If enabled, then rpc.gssd will be run when either -client or
> +    -server is started, and rpc.svcgssd will be run when -server
> +    is started
I like that fact that rpc.gssd is started by nfs-client but 
I don't like that API change. systemctl restart nfs-secure breaks 
 
> +
> + nfs-blkmap.target
> +    If enabled, then blkmapd will be run when nfs-client.target is
> +    started.
Unless someone steps up and says why this is needed or if it will 
ever be needed... I'm seriously thinking about dropping it from Fedora.

I think overall its workable but I just don't see the advantage 
of using .targets over .service files... 

steved.
