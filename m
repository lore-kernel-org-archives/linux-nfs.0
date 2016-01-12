Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59603 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbcALWGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2016 17:06:53 -0500
Date: Tue, 12 Jan 2016 17:06:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org, Gil Amsalem <gil.amsalem@primarydata.com>
Subject: Re: [PATCH] Reduce the probability to get port collision when asking
 for secure port. port collision = same port allocated to 2 different clients
 trying to connect to the same address.
Message-ID: <20160112220652.GB8256@fieldses.org>
References: <1449559654-14766-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1449559654-14766-2-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449559654-14766-2-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for a slow response.

I'm confused.  You're worried about two pynfs instances binding to the
same local port at the same time?  The kernel should prevent that,
shouldn't it?

--b.

On Tue, Dec 08, 2015 at 08:27:34AM +0100, Tigran Mkrtchyan wrote:
> From: Gil Amsalem <gil.amsalem@primarydata.com>
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  rpc/rpc.py | 18 +++++++-----------
>  1 file changed, 7 insertions(+), 11 deletions(-)
> 
> diff --git a/rpc/rpc.py b/rpc/rpc.py
> index 1a3ca38..8d88c62 100644
> --- a/rpc/rpc.py
> +++ b/rpc/rpc.py
> @@ -824,23 +824,19 @@ class ConnectionHandler(object):
>          defer.wait()
>          return pipe
>  
> -    def bindsocket(self, s, port=1):
> +    def bindsocket(self, s, start_port=1):
>          """Scan up through ports, looking for one we can bind to"""
>          # This is necessary when we need to use a 'secure' port
> -        using = port
> -        while 1:
> +        valid_ports = range(start_port, 1024)
> +        random.shuffle(valid_ports)
> +        for port in valid_ports:
>              try:
> -                s.bind(('', using))
> +                s.bind(('', port))
>                  return
>              except socket.error, why:
> -                if why[0] == errno.EADDRINUSE:
> -                    using += 1
> -                    if port < 1024 <= using:
> -                        # If we ask for a secure port, make sure we don't
> -                        # silently bind to a non-secure one
> -                        raise
> -                else:
> +                if why[0] != errno.EADDRINUSE:
>                      raise
> +        raise Exception('failed to find available secure port')
>  
>  
>      def expose(self, address, af, safe=True):
> -- 
> 2.5.0
