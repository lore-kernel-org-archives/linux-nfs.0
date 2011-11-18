Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:4278 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597Ab1KRQ6y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Nov 2011 11:58:54 -0500
Date: Fri, 18 Nov 2011 11:58:35 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: John Hughes <john@Calva.COM>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, peter staubach <peter.staubach@emc.com>
Message-ID: <775392619.77.1321635515842.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1020589474.75.1321635498473.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS
 errors
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please forgive me for speaking this aloud, but, dbus?

Matt

----- "John Hughes" <john@Calva.COM> wrote:

> On 18/11/11 17:27, peter.staubach@emc.com wrote:
> > Given that the poor user will be sitting, with almost nothing
> working because of the expired ticket, how does the user figure out
> what is going on or how does the admin help him?
> >
> > Some guidance seems like a good thing.  Is there really a problem
> with these messages being printed to the log?
> If you're sat at your console with nothing responding how are you
> going 
> to see the log messages?
> 
> The "ticket expired" messages are rate limited.
> 
> The "Error: state manager failed on NFSv4 server" messages are not
> rate 
> limited, but if you use my "rpc.gssd -e" hack they'll be written to
> the 
> log every 5 seconds all night long.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
