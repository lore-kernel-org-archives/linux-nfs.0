From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Strange NFS/reiserfs errors
Date: Fri, 15 Aug 2003 13:23:16 +0200
Sender: bernd-schubert@web.de
Message-ID: <200308151323.16172.bernd-schubert@web.de>
References: <3F3C7341.4020503@emageon.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <reiserfs-list-return-15315-reiserfs=m.gmane.org@namesys.com>
list-help: <mailto:reiserfs-list-help@namesys.com>
list-unsubscribe: <mailto:reiserfs-list-unsubscribe@namesys.com>
list-post: <mailto:reiserfs-list@namesys.com>
Errors-To: flx@namesys.com
To: Brian Tinsley <btinsley@emageon.com>,
 reiserfs-list@namesys.com
In-Reply-To: <3F3C7341.4020503@emageon.com>
List-ID: <nfs.lists.sourceforge.net>

Hi,

searching the archives of the reiserfs-ML and I guess also a general web 
search would show that this is fixed in 2.4.21!

Regards,
	Bernd


On Friday 15 August 2003 07:44, Brian Tinsley wrote:
> Hi! I've posted this to the NFS mailing list, but wanted to drop it here
> as well to see if anyone may provide further insight.
>
> ---------------------------
> Can anyone elaborate on what may have caused the following error:
>
> Aug 14 22:09:09 clarc02 kernel: nfsd-fh: found a name that I didn't
> expect: files/19
> Aug 14 22:09:40 clarc02 last message repeated 2314 times
> Aug 14 22:15:56 clarc02 last message repeated 1088 times
> Aug 14 22:17:10 clarc02 last message repeated 138 times
> Aug 14 22:19:03 clarc02 last message repeated 138 times
> Aug 14 22:20:53 clarc02 last message repeated 2 times
> Aug 14 22:21:30 clarc02 last message repeated 73 times
>
> The underlying filesystem is reiserfs and there was a high volume of
> writing taking place (or trying to) during this time. None of the writes
> succeeded as the client was returned EEXIST errors. However, the writes
> were reissued in full shortly after the last occurence and everything
> automagically started working properly again.
>
> I'm trying to decipher the source code, but it's a bit out of my area of
> expertise ;-)
>
> Thanks!
