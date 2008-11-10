From: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Subject: Re: [NFS] export dir thru 2 diff path names
Date: Mon, 10 Nov 2008 11:28:04 -0800
Message-ID: <620E93B2E5CC3B46BD811165E3335B8702F3759D@0461-its-exmb02.us.saic.com>
References: <478B90A1.5000900@bnl.gov><1200330387.7470.11.camel@heimdal.trondhjem.org><478B9A64.5030903@bnl.gov>
	<49147E79.6000508@bnl.gov><20081109155831.GA24508@fieldses.org>
	<49185984.8010500@bnl.gov><20081110164947.GA17050@fieldses.org>
	<491869F0.1000505@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F374A0@0461-its-exmb02.us.saic.com>
	<491882AB.6070908@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F37542@0461-its-exmb02.us.saic.com>
	<4918859C.6080608@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: "Sev Binello" <sev-IGkKxAqZmp0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36240 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbYKJT0S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 14:26:18 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KzcOt-0008FH-G6
	for linux-nfs@vger.kernel.org; Tue, 11 Nov 2008 06:26:15 +1100
In-Reply-To: <4918859C.6080608-IGkKxAqZmp0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That really is the 64K question.  During my initial testing, I exported
the parent directory.  Now I am explicitly exporting the installation
directories, where I see the exportfs message.  In the messages log file
on the server the mount request from the client is always the actual
directory.

Wayne 

> -----Original Message-----
> From: Sev Binello [mailto:sev-IGkKxAqZmp0@public.gmane.org] 
> Sent: Monday, November 10, 2008 1:04 PM
> To: Murata, Dennis
> Cc: J. Bruce Fields; nfs@lists.sourceforge.net
> Subject: Re: [NFS] export dir thru 2 diff path names
> 
> Hi -
>     Yeah, I see.
>     So it actually looks like you can do this.
>     I'm not 100% sure if safe --though it looks it -- so I'll 
> probably not use it for this application.
> 
> Thanks
> -Sev
> 
> Murata, Dennis wrote:
> > That is correct, exportfs only shows the actual directory.  
> The client 
> > seems to be able to mount the directory with either.
> >
> > Wayne
> >
> >   
> >> -----Original Message-----
> >> From: Sev Binello [mailto:sev-IGkKxAqZmp0@public.gmane.org]
> >> Sent: Monday, November 10, 2008 12:51 PM
> >> To: Murata, Dennis
> >> Cc: J. Bruce Fields; nfs@lists.sourceforge.net
> >> Subject: Re: [NFS] export dir thru 2 diff path names
> >>
> >> Murata, Dennis wrote:
> >>     
> >>> I just tested this on a SL4.7 (RHEL 4.7 variant) using a
> >>>       
> >> RHEL 4.4 nfs
> >>     
> >>> server.  I did get the messages from exportfs about
> >>>       
> >> duplicate export
> >>     
> >>> entries.  On the client I was able to mount both the
> >>>       
> >> symlink and the
> >>     
> >>> actual directory.  They look like separate mounts.  There are two 
> >>> entries in /proc/mounts and in /etc/mtab, one with the actual 
> >>> directory path, one with the symlink path.  I am using
> >>>       
> >> autofs to mount
> >>     
> >>> the directories, not hardcoded.  Are you using newer 
> distributions?
> >>>   
> >>>       
> >> I tested on RHEL 4.6.
> >> Interesting that you can still mount either one.
> >> On the server an exportfs only shows the real path as exported.
> >>
> >>     
> >>> What problems will I cause by doing this?  I am using the
> >>>       
> >> symlink path
> >>     
> >>> as the installation path for an application.  The idea is a newer 
> >>> version can be installed into a different directory, then after 
> >>> testing the symlink will be changed to the new 
> installation.  Other 
> >>> applications that reference the application will always use the 
> >>> symlink path, as well as any user scripts.
> >>>
> >>> Wayne
> >>>
> >>>   
> >>>       
> >>>> -----Original Message-----
> >>>> From: linux-nfs-owner@vger.kernel.org 
> >>>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Sev Binello
> >>>> Sent: Monday, November 10, 2008 11:06 AM
> >>>> To: J. Bruce Fields; nfs@lists.sourceforge.net
> >>>> Subject: Re: [NFS] export dir thru 2 diff path names
> >>>>
> >>>> J. Bruce Fields wrote:
> >>>>     
> >>>>         
> >>>>> On Mon, Nov 10, 2008 at 10:55:48AM -0500, Sev Binello wrote:
> >>>>>   
> >>>>>       
> >>>>>           
> >>>>>> Well the simplest approach doesn't work.
> >>>>>> i.e put symb link and actual path in the export file & try
> >>>>>>         
> >>>>>>             
> >>>> exporting
> >>>>     
> >>>>         
> >>>>>> it Exportfs dereferences the link and states that
> >>>>>>         
> >>>>>>             
> >>>> duplicates are not allowed.
> >>>>     
> >>>>         
> >>>>>>     
> >>>>>>         
> >>>>>>             
> >>>>> OK, makes sense.
> >>>>>
> >>>>> You could mount --bind the filesystem at the other location
> >>>>>       
> >>>>>           
> >>>> instead of
> >>>>     
> >>>>         
> >>>>> symlinking.
> >>>>>
> >>>>> The filehandles given to the client will be the same
> >>>>>           
> >> across the two
> >>     
> >>>>> exports.  If you mount both from the same client,
> >>>>>           
> >> behavior may vary
> >>     
> >>>>> across different clients (for example, as to whether they
> >>>>>       
> >>>>>           
> >>>> attempt to
> >>>>     
> >>>>         
> >>>>> share caches between the two), but I think it'd work.
> >>>>>
> >>>>> (The question "why??!!??" does come to mind, though.)
> >>>>>
> >>>>>   
> >>>>>       
> >>>>>           
> >>>> Need to make a path change to how file systems are mounted and 
> >>>> exported on the servers This then required a wholesale change to 
> >>>> clients so they mount  the correct path.
> >>>>  Not an issue for linux.
> >>>> But since we don't administer windows pcs and they also 
> mount the 
> >>>> same file system, wanted to see if we could let them 
> stay the way 
> >>>> they were for now.
> >>>>
> >>>> We're just going to go ahead and  have to coordinate this with 
> >>>> windows guys.
> >>>>
> >>>> -Sev
> >>>>     
> >>>>         
> >>>>> --b.
> >>>>>
> >>>>>   
> >>>>>       
> >>>>>           
> >>>>>> -Sev
> >>>>>>
> >>>>>> J. Bruce Fields wrote:
> >>>>>>     
> >>>>>>         
> >>>>>>             
> >>>>>>> On Fri, Nov 07, 2008 at 12:44:25PM -0500, Sev Binello wrote:
> >>>>>>>   
> >>>>>>>       
> >>>>>>>           
> >>>>>>>               
> >>>>>>>> Can anyone tell me if it's ok to export the same file system 
> >>>>>>>> through 2 different paths ( one is a link) ?
> >>>>>>>>     
> >>>>>>>>         
> >>>>>>>>             
> >>>>>>>>                 
> >>>>>>> I actually don't know.  You could try it and tell us what
> >>>>>>>           
> >>>>>>>               
> >>>> you find
> >>>>     
> >>>>         
> >>>>>>> out....
> >>>>>>>
> >>>>>>> If you're exporting something *containing* the symlink
> >>>>>>>           
> >>>>>>>               
> >>>> and expecting
> >>>>     
> >>>>         
> >>>>>>> the client to traverse into the filesystem, be aware that
> >>>>>>>           
> >>>>>>>               
> >>>> symlinks
> >>>>     
> >>>>         
> >>>>>>> over NFS are actually interpreted (and followed) on the
> >>>>>>>           
> >>>>>>>               
> >>>> client--so
> >>>>     
> >>>>         
> >>>>>>> they're interpreted as *client-side* paths, not server-side.
> >>>>>>>
> >>>>>>> If the path you're exporting is itself a symlink--it probably 
> >>>>>>> depends on how nfs-utils treats symlinks found in
> >>>>>>>           
> >>>>>>>               
> >>>> /etc/exports.  I'd
> >>>>     
> >>>>         
> >>>>>>> have to try it or check the code.
> >>>>>>>
> >>>>>>> Another way to export the filesystem in two different
> >>>>>>>           
> >>>>>>>               
> >>>> places would
> >>>>     
> >>>>         
> >>>>>>> be with mount --bind.
> >>>>>>>
> >>>>>>> --b.
> >>>>>>>   
> >>>>>>>       
> >>>>>>>           
> >>>>>>>               
> >>>>>> --
> >>>>>>
> >>>>>> Sev Binello
> >>>>>> Brookhaven National Laboratory
> >>>>>> Upton, New York
> >>>>>> 631-344-5647
> >>>>>> sev-IGkKxAqZmp0@public.gmane.org
> >>>>>>
> >>>>>>     
> >>>>>>         
> >>>>>>             
> >>>> --------------------------------------------------------------
> >>>> -----------
> >>>> This SF.Net email is sponsored by the Moblin Your Move 
> Developer's 
> >>>> challenge Build the coolest Linux based applications with
> >>>>         
> >> Moblin SDK
> >>     
> >>>> & win great prizes Grand prize is a trip for two to an 
> Open Source 
> >>>> event anywhere in the world 
> >>>> http://moblin-contest.org/redirect.php?banner_id=100&url=/
> >>>> _______________________________________________
> >>>> NFS maillist  -  NFS@lists.sourceforge.net 
> >>>> https://lists.sourceforge.net/lists/listinfo/nfs
> >>>> _______________________________________________
> >>>> Please note that nfs@lists.sourceforge.net is being discontinued.
> >>>> Please subscribe to linux-nfs@vger.kernel.org instead.
> >>>>     http://vger.kernel.org/vger-lists.html#linux-nfs
> >>>>
> >>>> --
> >>>> To unsubscribe from this list: send the line "unsubscribe
> >>>>         
> >> linux-nfs" 
> >>     
> >>>> in the body of a message to majordomo@vger.kernel.org More
> >>>>         
> >> majordomo
> >>     
> >>>> info at http://vger.kernel.org/majordomo-info.html
> >>>>
> >>>>     
> >>>>         
> >> --
> >>
> >> Sev Binello
> >> Brookhaven National Laboratory
> >> Upton, New York
> >> 631-344-5647
> >> sev-IGkKxAqZmp0@public.gmane.org
> >>
> >>
> >>     
> 
> 

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

