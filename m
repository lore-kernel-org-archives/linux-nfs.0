From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Thu, 4 Dec 2008 11:23:14 +0100
Message-ID: <20081204102314.GW47559@fit.vutbr.cz>
References: <1227620339.9425.99.camel@zakaz.uk.xensource.com> <1227621434.7057.33.camel@heimdal.trondhjem.org> <1227621877.9425.102.camel@zakaz.uk.xensource.com> <1227737539.31008.2.camel@localhost.localdomain> <1228090631.7112.11.camel@heimdal.trondhjem.org> <1228091380.7112.17.camel@heimdal.trondhjem.org> <20081202152256.GI47559@fit.vutbr.cz> <1228232222.3090.5.camel@heimdal.trondhjem.org> <20081202162625.GM47559@fit.vutbr.cz> <1228241407.3090.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:56028 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543AbYLEN7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 08:59:49 -0500
In-Reply-To: <1228241407.3090.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2008 at 01:10:07PM -0500, Trond Myklebust wrote:
> On Tue, 2008-12-02 at 17:26 +0100, Kasparek Tomas wrote:
> 
> > Did tried. The number should be seconds and defaults to 60, These
> > connections are still there after several hours. Changing it to 10 (sec)
> > and same behaviour. (BTW The server did not changed in last several months)
> 
> Are you seeing the same behaviour with 'netstat -t'?

yes:

root@pckasparek: ~# ssh root@pcnlp1 'netstat -pan | grep WAIT' | cut -c-85
tcp    0   0 147.229.12.146:989          147.229.176.14:2049 FIN_WAIT2
root@pckasparek: ~# ssh root@pcnlp1 'netstat -t | grep WAIT' | cut -c-85
tcp    0   0 pcnlp1.fit.vutbr.:ftps-data eva.fit.vutbr.cz:nfs FIN_WAIT2

but it should be the same, did't it? -t just selects TCP connections and
this is TCP connection so it shows the same

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

