Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:56968 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab3JaNfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 09:35:18 -0400
Date: Thu, 31 Oct 2013 09:35:12 -0400
From: Jim Rees <rees@umich.edu>
To: Robert Schiele <rschiele@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix race condition for parallel startup of statd
Message-ID: <20131031133512.GA12550@umich.edu>
References: <20131031055435.GA27362@ulegcprs1.emea.nsn-net.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131031055435.GA27362@ulegcprs1.emea.nsn-net.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Robert Schiele wrote:

  @@ -788,6 +794,11 @@ int start_statd(void)
   			}
   			if (nfs_probe_statd())
   				return 1;
  +			while (cnt--) {
  +				nanosleep(&ts, NULL);
  +				if (nfs_probe_statd())
  +					return 1;
  +			}
   		}
   	}
   #endif

Shouldn't this be something like:

			while (cnt--) {
				if (nfs_probe_statd())
					return 1;
				if (nanosleep(&ts, NULL) < 0)
					break;
			}

?
